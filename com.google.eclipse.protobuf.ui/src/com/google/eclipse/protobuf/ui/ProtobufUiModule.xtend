/*
 * Copyright (c) 2014 Google Inc.
 * 
 * All rights reserved. This program and the accompanying materials are made available under the terms of the Eclipse
 * Public License v1.0 which accompanies this distribution, and is available at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.google.eclipse.protobuf.ui

import static com.google.inject.name.Names.named
import static org.eclipse.ui.PlatformUI.isWorkbenchRunning
import com.google.eclipse.protobuf.preferences.general.GeneralPreferences
import com.google.eclipse.protobuf.resource.IResourceVerifier
import com.google.eclipse.protobuf.scoping.IImportResolver
import com.google.eclipse.protobuf.scoping.IUriResolver
import com.google.eclipse.protobuf.ui.builder.nature.ProtobufEditorCallback
import com.google.eclipse.protobuf.ui.documentation.ProtobufDocumentationProvider
import com.google.eclipse.protobuf.ui.editor.FileOutsideWorkspaceIconUpdater
import com.google.eclipse.protobuf.ui.editor.ProtobufUriEditorOpener
import com.google.eclipse.protobuf.ui.editor.hyperlinking.ProtobufHyperlinkDetector
import com.google.eclipse.protobuf.ui.editor.model.ProtobufDocumentProvider
import com.google.eclipse.protobuf.ui.editor.syntaxcoloring.HighlightingConfiguration
import com.google.eclipse.protobuf.ui.editor.syntaxcoloring.ProtobufAntlrTokenToAttributeIdMapper
import com.google.eclipse.protobuf.ui.editor.syntaxcoloring.ProtobufSemanticHighlightingCalculator
import com.google.eclipse.protobuf.ui.outline.LinkWithEditor
import com.google.eclipse.protobuf.ui.outline.ProtobufOutlinePage
import com.google.eclipse.protobuf.ui.parser.PreferenceDrivenProtobufParser
import com.google.eclipse.protobuf.ui.preferences.compiler.CompilerPreferences
import com.google.eclipse.protobuf.ui.preferences.editor.ignore.IgnoredExtensionsPreferences
import com.google.eclipse.protobuf.ui.preferences.editor.numerictag.NumericTagPreferences
import com.google.eclipse.protobuf.ui.preferences.editor.save.SaveActionsPreferences
import com.google.eclipse.protobuf.ui.preferences.misc.MiscellaneousPreferences
import com.google.eclipse.protobuf.ui.preferences.paths.PathsPreferences
import com.google.eclipse.protobuf.ui.resource.ProtobufServiceProvider
import com.google.eclipse.protobuf.ui.resource.ResourceVerifier
import com.google.eclipse.protobuf.ui.scoping.ImportResolver
import com.google.eclipse.protobuf.ui.scoping.UriResolver
import com.google.inject.Binder
import org.eclipse.jface.text.hyperlink.IHyperlinkDetector
import org.eclipse.ui.plugin.AbstractUIPlugin
import org.eclipse.ui.views.contentoutline.IContentOutlinePage
import org.eclipse.xtext.documentation.IEObjectDocumentationProvider
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator
import org.eclipse.xtext.parser.IParser
import org.eclipse.xtext.resource.IResourceServiceProvider
import org.eclipse.xtext.ui.LanguageSpecific
import org.eclipse.xtext.ui.editor.IURIEditorOpener
import org.eclipse.xtext.ui.editor.IXtextEditorCallback
import org.eclipse.xtext.ui.editor.model.XtextDocumentProvider
import org.eclipse.xtext.ui.editor.outline.actions.IOutlineContribution
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreInitializer
import org.eclipse.xtext.ui.editor.syntaxcoloring.AbstractAntlrTokenToAttributeIdMapper
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfiguration
import org.eclipse.xtext.ui.resource.IResourceSetProvider
import org.eclipse.xtext.ui.resource.SimpleResourceSetProvider

/** 
 * Registers components to be used within the IDE.
 * @author alruiz@google.com (Alex Ruiz)
 */
class ProtobufUiModule extends AbstractProtobufUiModule {
	new(AbstractUIPlugin plugin) {
		super(plugin)
	}

	def Class<? extends IImportResolver> bindImportResolver() {
		return ImportResolver
	}

	def Class<? extends IUriResolver> bindUriResolver() {
		return UriResolver
	}

	def Class<? extends IHighlightingConfiguration> bindHighlightingConfiguration() {
		return HighlightingConfiguration
	}

	override Class<? extends IContentOutlinePage> bindIContentOutlinePage() {
		return ProtobufOutlinePage
	}

	def Class<? extends IEObjectDocumentationProvider> bindIEObjectDocumentationProvider() {
		return ProtobufDocumentationProvider
	}

	override Class<? extends IHyperlinkDetector> bindIHyperlinkDetector() {
		return ProtobufHyperlinkDetector
	}

	def Class<? extends IParser> bindIParser() {
		return PreferenceDrivenProtobufParser
	}

	def Class<? extends IResourceServiceProvider> bindIResourceServiceProvider() {
		return ProtobufServiceProvider
	}

	override Class<? extends IResourceSetProvider> bindIResourceSetProvider() {
		return SimpleResourceSetProvider
	}

	def Class<? extends IResourceVerifier> bindIResourceVerifier() {
		return ResourceVerifier
	}

	def Class<? extends ISemanticHighlightingCalculator> bindISemanticHighlightingCalculator() {
		return ProtobufSemanticHighlightingCalculator
	}

	override Class<? extends IXtextEditorCallback> bindIXtextEditorCallback() {
		return ProtobufEditorCallback
	}

	def Class<? extends XtextDocumentProvider> bindXtextDocumentProvider() {
		return ProtobufDocumentProvider
	}

	def void configureFileOutsideWorkspaceIconUpdater(Binder binder) {
		binder.bind(IXtextEditorCallback).annotatedWith(named("FileOutsideWorkspaceIconUpdater")).to(
			FileOutsideWorkspaceIconUpdater)
	}

	override void configureLanguageSpecificURIEditorOpener(Binder binder) {
		if (!isWorkbenchRunning()) {
			return;
		}
		binder.bind(IURIEditorOpener).annotatedWith(LanguageSpecific).to(ProtobufUriEditorOpener)
	}

	def void configurePreferencesInitializers(Binder binder) {
		configurePreferenceInitializer(binder, "compilerPreferences", CompilerPreferences.Initializer)
		configurePreferenceInitializer(binder, "generalPreferences", GeneralPreferences.Initializer)
		configurePreferenceInitializer(binder, "ignoredExtensions", IgnoredExtensionsPreferences.Initializer)
		configurePreferenceInitializer(binder, "numericTagPreferences", NumericTagPreferences.Initializer)
		configurePreferenceInitializer(binder, "miscellaneousPreferences", MiscellaneousPreferences.Initializer)
		configurePreferenceInitializer(binder, "pathsPreferences", PathsPreferences.Initializer)
		configurePreferenceInitializer(binder, "saveActionsPreferences", SaveActionsPreferences.Initializer)
	}

	def private void configurePreferenceInitializer(Binder binder, String name,
		Class<? extends IPreferenceStoreInitializer> initializerType) {
		binder.bind(IPreferenceStoreInitializer).annotatedWith(named(name)).to(initializerType)
	}

	override void configureToggleLinkWithEditorOutlineContribution(Binder binder) {
		binder.bind(IOutlineContribution).annotatedWith(IOutlineContribution.LinkWithEditor).to(LinkWithEditor)
	}

	def Class<? extends AbstractAntlrTokenToAttributeIdMapper> bindAbstractAntlrTokenToAttributeIdMapper() {
		return ProtobufAntlrTokenToAttributeIdMapper
	}
}
