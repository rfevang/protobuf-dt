/*
 * Copyright (c) 2016 Google Inc.
 * 
 * All rights reserved. This program and the accompanying materials are
 * made available under the terms of the Eclipse Public License v1.0 which
 * accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.google.eclipse.protobuf.scoping

import static com.google.eclipse.protobuf.util.Tracer.DEBUG_SCOPING
import static com.google.eclipse.protobuf.validation.ProtobufResourceValidator.getScopeProviderTimingCollector
import com.google.eclipse.protobuf.naming.ProtobufQualifiedNameConverter
import com.google.eclipse.protobuf.naming.ProtobufQualifiedNameProvider
import com.google.eclipse.protobuf.protobuf.ComplexType
import com.google.eclipse.protobuf.protobuf.ComplexTypeLink
import com.google.eclipse.protobuf.protobuf.ComplexValue
import com.google.eclipse.protobuf.protobuf.ComplexValueField
import com.google.eclipse.protobuf.protobuf.CustomFieldOption
import com.google.eclipse.protobuf.protobuf.CustomOption
import com.google.eclipse.protobuf.protobuf.DefaultValueFieldOption
import com.google.eclipse.protobuf.protobuf.ExtensionFieldName
import com.google.eclipse.protobuf.protobuf.FieldName
import com.google.eclipse.protobuf.protobuf.Group
import com.google.eclipse.protobuf.protobuf.IndexedElement
import com.google.eclipse.protobuf.protobuf.LiteralLink
import com.google.eclipse.protobuf.protobuf.MessageField
import com.google.eclipse.protobuf.protobuf.NativeFieldOption
import com.google.eclipse.protobuf.protobuf.NativeOption
import com.google.eclipse.protobuf.protobuf.OneOf
import com.google.eclipse.protobuf.protobuf.OptionField
import com.google.eclipse.protobuf.protobuf.OptionSource
import com.google.eclipse.protobuf.protobuf.Package
import com.google.eclipse.protobuf.protobuf.Protobuf
import com.google.eclipse.protobuf.protobuf.TypeLink
import com.google.eclipse.protobuf.protobuf.ValueField
import com.google.eclipse.protobuf.util.EResources
import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.core.resources.IProject
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.jdt.annotation.Nullable
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.util.IResourceScopeCache
import java.util.ArrayList
import java.util.HashMap
import java.util.List

/** 
 * A scope provider for the Protobuf language.
 * @author atrookey@google.com (Alexander Rookey)
 */
class ProtobufScopeProvider extends AbstractDeclarativeScopeProvider {
	@Inject ProtoDescriptorProvider descriptorProvider
	@Inject IResourceScopeCache cache
	@Inject ProtobufQualifiedNameConverter nameConverter
	@Inject ProtobufQualifiedNameProvider nameProvider

	def private ImportNormalizer createImportNormalizerForEObject(EObject element, boolean ignoreCase) {
		var QualifiedName name = nameProvider.getFullyQualifiedName(element)
		return getLocalScopeProvider().createImportedNamespaceResolver(name.toString(), ignoreCase)
	}

	def private List<ImportNormalizer> createImportNormalizersForComplexType(ComplexType complexType,
		boolean ignoreCase) {
		var List<ImportNormalizer> normalizers = new ArrayList()
		normalizers.add(createImportNormalizerForEObject(complexType, ignoreCase))
		normalizers.addAll(createImportNormalizersForOneOf(complexType.eContents(), ignoreCase))
		return normalizers
	}

	def private List<ImportNormalizer> createImportNormalizersForOneOf(EList<EObject> children, boolean ignoreCase) {
		var List<ImportNormalizer> normalizers = new ArrayList()
		for (EObject child : children) {
			if (child instanceof OneOf) {
				normalizers.add(createImportNormalizerForEObject(child, ignoreCase))
				normalizers.addAll(createImportNormalizersForOneOf(child.eContents(), ignoreCase))
			}
		}
		return normalizers
	}

	/** 
	 * An {@code IndexedElement} can be a MessageField or Group. When scoping types {@code FieldName},{@code LiteralLink}, or {@code OptionField} that are all related to protocol buffer options, a
	 * scope can be created by traversing the EMF Model to find a suitable {@code IndexedElement}, and
	 * then creating an import normalized scope for the {@code ComplexType} of the {@codeMessageField} or {@code Group}.
	 * <p>For example: <pre>
	 * enum MyEnum {
	 * FOO = 1;
	 * }
	 * extend google.protobuf.ServiceOptions {
	 * optional MyEnum my_service_option = 50005;
	 * }
	 * service MyService {
	 * option (my_service_option) = FOO;
	 * }
	 * </pre>
	 * To scope the {@code LiteralLink} {@code FOO} in {@code MyService}, the {@code MessageField}{@code my_service_option} is found by traversing the model. The method
	 * createNormalizedScopeForIndexedElement(IndexedElement, EReference) creates and returns an
	 * import normalized scope for the type of the {@code MessageField}, {@code MyEnum}.
	 */
	def private IScope createNormalizedScopeForIndexedElement(IndexedElement indexedElement, EReference reference) {
		var HashMap<EReference, IScope> scopeMap = cache.get(indexedElement, indexedElement.eResource(), ([|
			return new HashMap<EReference, IScope>()
		] as Provider<HashMap<EReference, IScope>>))
		if (!scopeMap.containsKey(reference)) {
			var IScope scope = null
			if (indexedElement instanceof MessageField) {
				var TypeLink typeLink = ((indexedElement as MessageField)).getType()
				if (typeLink instanceof ComplexTypeLink) {
					var ComplexType complexType = ((typeLink as ComplexTypeLink)).getTarget()
					scope = getGlobalScopeProvider().getScope(complexType.eResource(), reference)
					var List<ImportNormalizer> normalizers = createImportNormalizersForComplexType(complexType, false)
					scope = createProtobufImportScope(scope, complexType, reference)
					((scope as ProtobufImportScope)).addAllNormalizers(normalizers)
				}
			}
			if (indexedElement instanceof Group) {
				var Group group = (indexedElement as Group)
				scope = getGlobalScopeProvider().getScope(group.eResource(), reference)
				var ImportNormalizer normalizer = createImportNormalizerForEObject(group, false)
				scope = createProtobufImportScope(scope, group, reference)
				((scope as ProtobufImportScope)).addNormalizer(normalizer)
			}
			scopeMap.put(reference, scope)
		}
		return scopeMap.get(reference)
	}

	def private IScope createProtobufImportScope(IScope parent, EObject context, EReference reference) {
		var IScope scope = parent
		if (context.eContainer() === null) {
			scope = getLocalScopeProvider().getResourceScope(scope, context, reference)
		} else {
			scope = createProtobufImportScope(scope, context.eContainer(), reference)
		}
		return getLocalScopeProvider().getLocalElementsScope(scope, context, reference)
	}

	/** 
	 * Returns descriptor associated with the current project. 
	 */
	/* @Nullable*/ def private Resource getDescriptorResource(EObject context) {
		var IProject project = EResources::getProjectOf(context.eResource())
		var ResourceSet resourceSet = context.eResource().getResourceSet()
		var ProtoDescriptorProvider.ProtoDescriptorInfo descriptorInfo = descriptorProvider.primaryDescriptor(project)
		return resourceSet.getResource(descriptorInfo.location, true)
	}

	/** 
	 * Returns the global scope provider. 
	 */
	def private ProtobufImportUriGlobalScopeProvider getGlobalScopeProvider() {
		return getLocalScopeProvider().getGlobalScopeProvider()
	}

	/** 
	 * Returns the local scope provider. 
	 */
	def private ProtobufImportedNamespaceAwareLocalScopeProvider getLocalScopeProvider() {
		return (super.getDelegate() as ProtobufImportedNamespaceAwareLocalScopeProvider)
	}

	// TODO (atrookey) Create utility for getting package.
	def private String getPackageOfResource(Resource resource) {
		return cache.get("Package", resource, ([|
			var Protobuf protobuf
			if (resource !== null && (protobuf = resource.getContents().get(0) as Protobuf) !== null) {
				for (EObject content : protobuf.getElements()) {
					if (content instanceof Package) {
						return ((content as Package)).getImportedNamespace()
					}
				}
			}
			return ""
		] as Provider<String>))
	}

	override IScope getScope(EObject context, EReference reference) {
		if (DEBUG_SCOPING) {
			getScopeProviderTimingCollector().startTimer()
		}
		var IScope scope = super.getScope(context, reference)
		if (DEBUG_SCOPING) {
			getScopeProviderTimingCollector().stopTimer()
		}
		return scope
	}

	/** 
	 * Scopes the {@code FieldName}.
	 * <p>For example: <pre>
	 * message FooOptions {
	 * optional int32 opt1 = 1;
	 * }
	 * extend google.protobuf.FieldOptions {
	 * optional FooOptions foo_options = 1234;
	 * }
	 * message Bar {
	 * optional int32 b = 1 [(foo_options) = { opt1: 123 }];
	 * }
	 * </pre>
	 * The {@code NormalFieldName} {@code opt1} contains a cross-reference to {@code FooOptions.opt1}.
	 */
	def IScope scope_FieldName_target(FieldName fieldName, EReference reference) {
		if (fieldName instanceof ExtensionFieldName) {
			return getLocalScopeProvider().getResourceScope(fieldName.eResource(), reference)
		}
		var IndexedElement indexedElement = null
		var OptionSource optionSource = null
		var EObject valueField = fieldName.eContainer()
		if (valueField instanceof ValueField) {
			var EObject complexValue = valueField.eContainer()
			if (complexValue instanceof ComplexValue) {
				var EObject unknownOption = complexValue.eContainer()
				if (unknownOption instanceof ComplexValueField) {
					indexedElement = ((unknownOption as ComplexValueField)).getName().getTarget()
				}
				if (unknownOption instanceof NativeFieldOption) {
					var NativeFieldOption nativeFieldOption = (unknownOption as NativeFieldOption)
					optionSource = nativeFieldOption.getSource()
				}
				if (unknownOption instanceof CustomFieldOption) {
					var CustomFieldOption customFieldOption = (unknownOption as CustomFieldOption)
					optionSource = customFieldOption.getSource()
				}
				if (unknownOption instanceof NativeOption) {
					var NativeOption option = (unknownOption as NativeOption)
					optionSource = option.getSource()
				}
				if (unknownOption instanceof CustomOption) {
					var CustomOption option = (unknownOption as CustomOption)
					optionSource = option.getSource()
				}
				if (optionSource !== null) {
					indexedElement = optionSource.getTarget()
				}
				if (indexedElement instanceof MessageField) {
					return createNormalizedScopeForIndexedElement(indexedElement, reference)
				}
			}
		}
		return null
	}

	/** 
	 * Creates a scope containing elements of type {@code Literal} that can be referenced with their
	 * local name only.
	 * <p>For example: <pre>
	 * enum MyEnum {
	 * FOO = 1;
	 * }
	 * extend google.protobuf.ServiceOptions {
	 * optional MyEnum my_service_option = 50005;
	 * }
	 * service MyService {
	 * option (my_service_option) = FOO;
	 * }
	 * </pre>
	 * The {@code LiteralLink} {@code FOO} contains a cross-reference to {@code MyEnum.FOO}.
	 */
	/* @Nullable*/ def IScope scope_LiteralLink_target(LiteralLink literalLink, EReference reference) {
		var EObject container = literalLink.eContainer()
		var IndexedElement indexedElement = null
		if (container instanceof DefaultValueFieldOption) {
			container = container.eContainer()
			if (container instanceof IndexedElement) {
				indexedElement = container as IndexedElement
			}
		}
		if (container instanceof NativeFieldOption) {
			indexedElement = ((container as NativeFieldOption)).getSource().getTarget()
		}
		if (container instanceof NativeOption) {
			indexedElement = ((container as NativeOption)).getSource().getTarget()
		}
		if (container instanceof CustomFieldOption) {
			var EList<OptionField> fields = ((container as CustomFieldOption)).getFields()
			if (!fields.isEmpty()) {
				indexedElement = fields.get(fields.size() - 1).getTarget()
			} else {
				indexedElement = ((container as CustomFieldOption)).getSource().getTarget()
			}
		}
		if (container instanceof CustomOption) {
			var EList<OptionField> fields = ((container as CustomOption)).getFields()
			if (!fields.isEmpty()) {
				indexedElement = fields.get(fields.size() - 1).getTarget()
			} else {
				indexedElement = ((container as CustomOption)).getSource().getTarget()
			}
		}
		return createNormalizedScopeForIndexedElement(indexedElement, reference)
	}

	/** 
	 * Recursively scopes the {@code OptionField} starting with the {@code OptionSource}.
	 * <p>For example: <pre>
	 * message Code {
	 * optional double number = 1;
	 * }
	 * message Type {
	 * optional Code code = 1;
	 * }
	 * extend proto2.FieldOptions {
	 * optional Type type = 1000;
	 * }
	 * message Person {
	 * optional bool active = 1 [(type).code.number = 68];
	 * }
	 * </pre>
	 * The {@code OptionField} {@code number} contains a cross-reference to {@code Code.number}.
	 */
	def IScope scope_OptionField_target(OptionField optionField, EReference reference) {
		var IScope scope = getLocalScopeProvider().getResourceScope(optionField.eResource(), reference)
		var EObject customOption = optionField.eContainer()
		if (customOption !== null) {
			var OptionSource optionSource = null
			var EList<OptionField> fields = null
			if (customOption instanceof CustomFieldOption) {
				optionSource = ((customOption as CustomFieldOption)).getSource()
				fields = ((customOption as CustomFieldOption)).getFields()
			}
			if (customOption instanceof CustomOption) {
				optionSource = ((customOption as CustomOption)).getSource()
				fields = ((customOption as CustomOption)).getFields()
			}
			if (optionSource !== null && fields !== null) {
				var int index = fields.indexOf(optionField)
				if (index < 0 || fields.size() <= index) {
					throw new IllegalArgumentException(
						'''index is «index» but field.size() is «fields.size()»'''.toString)
				}
				var IndexedElement indexedElement = null
				if (index === 0) {
					indexedElement = optionSource.getTarget()
				} else {
					indexedElement = fields.get(index - 1).getTarget()
				}
				return createNormalizedScopeForIndexedElement(indexedElement, reference)
			}
		}
		return scope
	}

	/** 
	 * Creates a scope containing the default options defined in descriptor.proto.
	 * <p>For example: <pre>
	 * option java_package = "com.example.foo";
	 * </pre>
	 * The {@code OptionSource} {@code java_package} contains a cross-reference to {@codegoogle.protobuf.FileOptions.java_package} defined in descriptor.proto.
	 */
	def IScope scope_OptionSource_target(OptionSource optionSource, EReference reference) {
		val String optionType = OptionType::typeOf(optionSource).messageName()
		val Resource resource = optionSource.eResource()
		var IScope descriptorScope = cache.get(optionType, resource, ([|
			var IScope scope = getGlobalScopeProvider().getScope(resource, reference)
			var Resource descriptorResource = getDescriptorResource(optionSource)
			var String descriptorMessage = getPackageOfResource(descriptorResource) + nameConverter.getDelimiter() +
				optionType
			var ImportNormalizer normalizer = getLocalScopeProvider().
				createImportedNamespaceResolver(descriptorMessage, false)
			scope = createProtobufImportScope(scope, getDescriptorResource(optionSource).getContents().get(0),
				reference)
			((scope as ProtobufImportScope)).addNormalizer(normalizer)
			return scope
		] as Provider<IScope>))
		return createProtobufImportScope(descriptorScope, optionSource, reference)
	}
}
