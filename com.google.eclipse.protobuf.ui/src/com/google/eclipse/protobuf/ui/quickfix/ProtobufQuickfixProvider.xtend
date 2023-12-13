/*
 * Copyright (c) 2014 Google Inc.
 * 
 * All rights reserved. This program and the accompanying materials are made available under the terms of the Eclipse
 * Public License v1.0 which accompanies this distribution, and is available at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.google.eclipse.protobuf.ui.quickfix

import static com.google.eclipse.protobuf.protobuf.BOOL.FALSE
import static com.google.eclipse.protobuf.protobuf.BOOL.TRUE
import static com.google.eclipse.protobuf.ui.quickfix.Messages.changeValueDescription
import static com.google.eclipse.protobuf.ui.quickfix.Messages.changeValueLabel
import static com.google.eclipse.protobuf.ui.quickfix.Messages.regenerateTagNumberDescription
import static com.google.eclipse.protobuf.ui.quickfix.Messages.regenerateTagNumberLabel
import static com.google.eclipse.protobuf.ui.quickfix.Messages.removeDuplicatePackageLabel
import static com.google.eclipse.protobuf.util.Strings.quote
import static com.google.eclipse.protobuf.validation.DataTypeValidator.EXPECTED_BOOL_ERROR
import static com.google.eclipse.protobuf.validation.DataTypeValidator.EXPECTED_STRING_ERROR
import static com.google.eclipse.protobuf.validation.ProtobufValidator.INVALID_FIELD_TAG_NUMBER_ERROR
import static com.google.eclipse.protobuf.validation.ProtobufValidator.MISSING_MODIFIER_ERROR
import static com.google.eclipse.protobuf.validation.ProtobufValidator.MORE_THAN_ONE_PACKAGE_ERROR
import static com.google.eclipse.protobuf.validation.ProtobufValidator.REQUIRED_IN_PROTO3_ERROR
import static com.google.eclipse.protobuf.validation.ProtobufValidator.SYNTAX_IS_NOT_KNOWN_ERROR
import static org.eclipse.emf.ecore.util.EcoreUtil.remove
import static org.eclipse.xtext.nodemodel.util.NodeModelUtils.findActualNodeFor
import com.google.eclipse.protobuf.grammar.CommonKeyword
import com.google.eclipse.protobuf.model.util.INodes
import com.google.eclipse.protobuf.model.util.IndexedElements
import com.google.eclipse.protobuf.model.util.Syntaxes
import com.google.eclipse.protobuf.naming.NameResolver
import com.google.eclipse.protobuf.protobuf.BOOL
import com.google.eclipse.protobuf.protobuf.BooleanLink
import com.google.eclipse.protobuf.protobuf.FieldOption
import com.google.eclipse.protobuf.protobuf.IndexedElement
import com.google.eclipse.protobuf.protobuf.MessageField
import com.google.eclipse.protobuf.protobuf.ModifierEnum
import com.google.eclipse.protobuf.protobuf.Package
import com.google.eclipse.protobuf.protobuf.ProtobufFactory
import com.google.eclipse.protobuf.protobuf.StringLink
import com.google.eclipse.protobuf.protobuf.StringLiteral
import com.google.eclipse.protobuf.protobuf.Syntax
import com.google.eclipse.protobuf.protobuf.Value
import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import org.eclipse.xtext.ui.editor.model.edit.IModificationContext
import org.eclipse.xtext.ui.editor.model.edit.ISemanticModification
import org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider
import org.eclipse.xtext.ui.editor.quickfix.Fix
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor
import org.eclipse.xtext.util.concurrent.IUnitOfWork
import org.eclipse.xtext.validation.Issue

/** 
 * @author alruiz@google.com (Alex Ruiz)
 */
class ProtobufQuickfixProvider extends DefaultQuickfixProvider {
	static final String ICON_FOR_CHANGE = "change.gif"
	@Inject IndexedElements indexedElements
	@Inject NameResolver nameResolver
	@Inject INodes nodes
	@Inject Syntaxes syntaxes

	@Fix(SYNTAX_IS_NOT_KNOWN_ERROR) def void changeSyntaxToProto2(Issue issue, IssueResolutionAcceptor acceptor) {
		var ISemanticModification modification = [ EObject element, IModificationContext context |
			var Syntax syntax = (element as Syntax)
			syntaxes.setName(syntax, Syntaxes.PROTO2)
		]
		var String description = String.format(changeValueDescription, "syntax", quote(Syntaxes.PROTO2))
		var String label = String.format(changeValueLabel, Syntaxes.PROTO2)
		acceptor.accept(issue, label, description, ICON_FOR_CHANGE, modification)
	}

	@Fix(SYNTAX_IS_NOT_KNOWN_ERROR) def void changeSyntaxToProto3(Issue issue, IssueResolutionAcceptor acceptor) {
		var ISemanticModification modification = [ EObject element, IModificationContext context |
			var Syntax syntax = (element as Syntax)
			syntaxes.setName(syntax, Syntaxes.PROTO3)
		]
		var String description = String.format(changeValueDescription, "syntax", quote(Syntaxes.PROTO3))
		var String label = String.format(changeValueLabel, Syntaxes.PROTO3)
		acceptor.accept(issue, label, description, ICON_FOR_CHANGE, modification)
	}

	@Fix(INVALID_FIELD_TAG_NUMBER_ERROR) def void regenerateTagNumber(Issue issue, IssueResolutionAcceptor acceptor) {
		var ISemanticModification modification = [ EObject element, IModificationContext context |
			var IndexedElement e = (element as IndexedElement)
			var long tagNumber = indexedElements.calculateNewIndexFor(e)
			indexedElements.setIndexTo(e, tagNumber)
		]
		acceptor.accept(issue, regenerateTagNumberLabel, regenerateTagNumberDescription, "field.gif", modification)
	}

	@Fix(MORE_THAN_ONE_PACKAGE_ERROR) def void removeDuplicatePackage(Issue issue, IssueResolutionAcceptor acceptor) {
		val Package aPackage = element(issue, Package)
		if (aPackage === null) {
			return;
		}
		var ISemanticModification modification = [ EObject element, IModificationContext context |
			if (element === aPackage) {
				remove(aPackage)
			}
		]
		var INode node = findActualNodeFor(aPackage)
		var String description = nodes.textOf(node)
		acceptor.accept(issue, removeDuplicatePackageLabel, description, "remove.gif", modification)
	}

	@Fix(MISSING_MODIFIER_ERROR) def void changeModifierToRequired(Issue issue, IssueResolutionAcceptor acceptor) {
		var ISemanticModification modification = [ EObject element, IModificationContext context |
			var MessageField field = (element as MessageField)
			field.setModifier(ModifierEnum.REQUIRED)
		]
		var String description = String.format(changeValueDescription, "modifier", "required")
		var String label = String.format(changeValueLabel, "required")
		acceptor.accept(issue, label, description, ICON_FOR_CHANGE, modification)
	}

	@Fix(MISSING_MODIFIER_ERROR) def void changeModifierToRepeated(Issue issue, IssueResolutionAcceptor acceptor) {
		var ISemanticModification modification = [ EObject element, IModificationContext context |
			var MessageField field = (element as MessageField)
			field.setModifier(ModifierEnum.REPEATED)
		]
		var String description = String.format(changeValueDescription, "modifier", "repeated")
		var String label = String.format(changeValueLabel, "repeated")
		acceptor.accept(issue, label, description, ICON_FOR_CHANGE, modification)
	}

	@Fix(MISSING_MODIFIER_ERROR) def void changeModifierToOptional(Issue issue, IssueResolutionAcceptor acceptor) {
		var ISemanticModification modification = [ EObject element, IModificationContext context |
			var MessageField field = (element as MessageField)
			field.setModifier(ModifierEnum.OPTIONAL)
		]
		var String description = String.format(changeValueDescription, "modifier", "optional")
		var String label = String.format(changeValueLabel, "optional")
		acceptor.accept(issue, label, description, ICON_FOR_CHANGE, modification)
	}

	@Fix(REQUIRED_IN_PROTO3_ERROR) def void changeModifierToOptionalOnRequired(Issue issue,
		IssueResolutionAcceptor acceptor) {
		var ISemanticModification modification = [ EObject element, IModificationContext context |
			var MessageField field = (element as MessageField)
			field.setModifier(ModifierEnum.OPTIONAL)
		]
		var String description = String.format(changeValueDescription, "modifier", "optional")
		var String label = String.format(changeValueLabel, "optional")
		acceptor.accept(issue, label, description, ICON_FOR_CHANGE, modification)
	}

	@Fix(EXPECTED_BOOL_ERROR) def void changeValueToTrue(Issue issue, IssueResolutionAcceptor acceptor) {
		var EObject element = elementIn(issue)
		if (element instanceof FieldOption) {
			var FieldOption option = (element as FieldOption)
			changeValue(option, linkTo(TRUE), CommonKeyword.TRUE, issue, acceptor)
		}
	}

	@Fix(EXPECTED_BOOL_ERROR) def void changeValueToFalse(Issue issue, IssueResolutionAcceptor acceptor) {
		var EObject element = elementIn(issue)
		if (element instanceof FieldOption) {
			var FieldOption option = (element as FieldOption)
			changeValue(option, linkTo(FALSE), CommonKeyword.FALSE, issue, acceptor)
		}
	}

	// TODO rename BooleanLink to BoolLink
	def private BooleanLink linkTo(BOOL value) {
		var BooleanLink link = ProtobufFactory.eINSTANCE.createBooleanLink()
		link.setTarget(value)
		return link
	}

	@Fix(EXPECTED_STRING_ERROR) def void changeValueToEmptyString(Issue issue, IssueResolutionAcceptor acceptor) {
		var EObject element = elementIn(issue)
		if (element instanceof FieldOption) {
			var FieldOption option = (element as FieldOption)
			var String valueToPropose = ""
			changeValue(option, linkTo(valueToPropose), valueToPropose, issue, acceptor)
		}
	}

	def private StringLink linkTo(String value) {
		var StringLink link = ProtobufFactory.eINSTANCE.createStringLink()
		var StringLiteral literal = ProtobufFactory.eINSTANCE.createStringLiteral()
		literal.getChunks().add(value)
		link.setTarget(literal)
		return link
	}

	def private void changeValue(FieldOption option, Value newValue, Object proposedValue, Issue issue,
		IssueResolutionAcceptor acceptor) {
		var ISemanticModification modification = [ EObject element, IModificationContext context |
			option.setValue(newValue)
		]
		var String name = nameResolver.nameOf(option)
		var String description = String.format(changeValueDescription, name, proposedValue)
		var String label = String.format(changeValueLabel, proposedValue)
		acceptor.accept(issue, label, description, ICON_FOR_CHANGE, modification)
	}

	def private EObject elementIn(Issue issue) {
		return element(issue, EObject)
	}

	def private <T extends EObject> T element(Issue issue, Class<T> type) {
		var IModificationContext modificationContext = getModificationContextFactory().createModificationContext(issue)
		var IXtextDocument xtextDocument = modificationContext.getXtextDocument()
		return xtextDocument.readOnly([ XtextResource state |
			var EObject e = state.getEObject(issue.getUriToProblem().fragment())
			return if(type.isInstance(e)) type.cast(e) else null
		])
	}
}
