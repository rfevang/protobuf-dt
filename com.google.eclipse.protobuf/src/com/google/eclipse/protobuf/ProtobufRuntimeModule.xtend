/*
 * Copyright (c) 2014 Google Inc.
 * 
 * All rights reserved. This program and the accompanying materials are made available under the terms of the Eclipse
 * Public License v1.0 which accompanies this distribution, and is available at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.google.eclipse.protobuf

import com.google.eclipse.protobuf.conversion.ProtobufTerminalConverters
import com.google.eclipse.protobuf.linking.ProtobufResource
import com.google.eclipse.protobuf.naming.ProtobufQualifiedNameConverter
import com.google.eclipse.protobuf.naming.ProtobufQualifiedNameProvider
import com.google.eclipse.protobuf.resource.FastXtextResourceSet
import com.google.eclipse.protobuf.resource.GlobalResourceServiceProvider
import com.google.eclipse.protobuf.scoping.ExtensionRegistryProvider
import com.google.eclipse.protobuf.scoping.ProtobufCaseInsensitivityHelper
import com.google.eclipse.protobuf.validation.ProtobufResourceValidator
import com.google.eclipse.protobuf.validation.ProtobufSyntaxErrorMessageProvider
import com.google.inject.Binder
import org.eclipse.core.runtime.IExtensionRegistry
import org.eclipse.xtext.conversion.IValueConverterService
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider
import org.eclipse.xtext.resource.IGlobalServiceProvider
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.scoping.ICaseInsensitivityHelper
import org.eclipse.xtext.validation.IResourceValidator

/** 
 * Use this class to register components to be used at runtime / without the Equinox extension
 * registry.
 */
class ProtobufRuntimeModule extends AbstractProtobufRuntimeModule {
	def Class<? extends IGlobalServiceProvider> bindIGlobalServiceProvider() {
		return GlobalResourceServiceProvider
	}

	def Class<? extends IQualifiedNameConverter> bindIQualifiedNameConverter() {
		return ProtobufQualifiedNameConverter
	}

	def Class<? extends ICaseInsensitivityHelper> bindICaseInsensitivityHelper() {
		return ProtobufCaseInsensitivityHelper
	}

	override Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
		return ProtobufQualifiedNameProvider
	}

	def Class<? extends IResourceValidator> bindIResourceValidator() {
		return ProtobufResourceValidator
	}

	def Class<? extends ISyntaxErrorMessageProvider> bindISyntaxErrorMessageProvider() {
		return ProtobufSyntaxErrorMessageProvider
	}

	override Class<? extends IValueConverterService> bindIValueConverterService() {
		return ProtobufTerminalConverters
	}

	override Class<? extends XtextResource> bindXtextResource() {
		return ProtobufResource
	}

	override Class<? extends XtextResourceSet> bindXtextResourceSet() {
		return FastXtextResourceSet
	}

	def void configureExtensionRegistry(Binder binder) {
		binder.bind(IExtensionRegistry).toProvider(ExtensionRegistryProvider)
	}
}
