/*
 * Copyright (c) 2011 Google Inc.
 * 
 * All rights reserved. This program and the accompanying materials are made available under the terms of the Eclipse
 * Public License v1.0 which accompanies this distribution, and is available at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.google.eclipse.protobuf.ui.contentassist

import static com.google.eclipse.protobuf.grammar.CommonKeyword.CLOSING_BRACKET
import static com.google.eclipse.protobuf.grammar.CommonKeyword.EQUAL
import static com.google.eclipse.protobuf.grammar.CommonKeyword.FALSE
import static com.google.eclipse.protobuf.grammar.CommonKeyword.NAN
import static com.google.eclipse.protobuf.grammar.CommonKeyword.OPENING_BRACKET
import static com.google.eclipse.protobuf.grammar.CommonKeyword.OPENING_CURLY_BRACKET
import static com.google.eclipse.protobuf.grammar.CommonKeyword.SYNTAX
import static com.google.eclipse.protobuf.grammar.CommonKeyword.TRUE
import static com.google.eclipse.protobuf.protobuf.ModifierEnum.OPTIONAL
import static com.google.eclipse.protobuf.protobuf.ProtobufPackage.Literals.LITERAL
import static com.google.eclipse.protobuf.ui.grammar.CompoundElement.DEFAULT_EQUAL_IN_BRACKETS
import static com.google.eclipse.protobuf.ui.grammar.CompoundElement.DEFAULT_EQUAL_STRING_IN_BRACKETS
import static com.google.eclipse.protobuf.ui.grammar.CompoundElement.EMPTY_STRING
import static com.google.eclipse.protobuf.ui.grammar.CompoundElement.EQUAL_PROTO2_IN_QUOTES
import static com.google.eclipse.protobuf.ui.grammar.CompoundElement.EQUAL_PROTO3_IN_QUOTES
import static com.google.eclipse.protobuf.ui.grammar.CompoundElement.PROTO2_IN_QUOTES
import static com.google.eclipse.protobuf.ui.grammar.CompoundElement.PROTO3_IN_QUOTES
import static com.google.eclipse.protobuf.util.CommonWords.space
import static java.lang.String.valueOf
import static org.eclipse.xtext.EcoreUtil2.getAllContentsOfType
import static org.eclipse.xtext.util.Strings.toFirstLower
import com.google.eclipse.protobuf.grammar.CommonKeyword
import com.google.eclipse.protobuf.model.util.IndexedElements
import com.google.eclipse.protobuf.model.util.Literals
import com.google.eclipse.protobuf.model.util.MessageFields
import com.google.eclipse.protobuf.model.util.Options
import com.google.eclipse.protobuf.protobuf.AbstractOption
import com.google.eclipse.protobuf.protobuf.ComplexValue
import com.google.eclipse.protobuf.protobuf.CustomFieldOption
import com.google.eclipse.protobuf.protobuf.CustomOption
import com.google.eclipse.protobuf.protobuf.DefaultValueFieldOption
import com.google.eclipse.protobuf.protobuf.Enum
import com.google.eclipse.protobuf.protobuf.FieldName
import com.google.eclipse.protobuf.protobuf.IndexedElement
import com.google.eclipse.protobuf.protobuf.Literal
import com.google.eclipse.protobuf.protobuf.MessageField
import com.google.eclipse.protobuf.protobuf.ModifierEnum
import com.google.eclipse.protobuf.protobuf.Option
import com.google.eclipse.protobuf.protobuf.SimpleValueField
import com.google.eclipse.protobuf.ui.grammar.CompoundElement
import com.google.eclipse.protobuf.ui.labeling.Images
import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.jface.text.contentassist.ICompletionProposal
import org.eclipse.jface.viewers.StyledString
import org.eclipse.swt.custom.StyledText
import org.eclipse.swt.graphics.Image
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.ui.PluginImageHelper
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor

/** 
 * @author alruiz@google.com (Alex Ruiz)
 * @see <a href="http://www.eclipse.org/Xtext/documentation/310_eclipse_support.html#content-assist">Xtext Content Assist</a>
 */
class ProtobufProposalProvider extends AbstractProtobufProposalProvider {
	@Inject Images images
	@Inject IndexedElements indexedElements
	@Inject PluginImageHelper imageHelper
	@Inject Literals literals
	@Inject MessageFields messageFields
	@Inject Options options

	override void completeProtobuf_Syntax(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
	}

	override void completeSyntax_Name(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		proposeAndAccept(PROTO2_IN_QUOTES, context, acceptor)
		proposeAndAccept(PROTO3_IN_QUOTES, context, acceptor)
	}

	override void complete_Syntax(EObject model, RuleCall ruleCall, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var String proposal = SYNTAX + space() + EQUAL_PROTO2_IN_QUOTES
		proposeAndAccept(proposal, imageHelper.getImage(images.imageFor(SYNTAX)), context, acceptor)
		proposal = SYNTAX + space() + EQUAL_PROTO3_IN_QUOTES
		proposeAndAccept(proposal, imageHelper.getImage(images.imageFor(SYNTAX)), context, acceptor)
	}

	override void complete_ID(EObject model, RuleCall ruleCall, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
	}

	override void complete_CHUNK(EObject model, RuleCall ruleCall, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
	}

	override void completeKeyword(Keyword keyword, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		if (keyword === null) {
			return;
		}
		var boolean proposalWasHandledAlready = completeKeyword(keyword.getValue(), context, acceptor)
		if (proposalWasHandledAlready) {
			return;
		}
		super.completeKeyword(keyword, context, acceptor)
	}

	def private boolean completeKeyword(String keyword, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		if (isLastWordFromCaretPositionEqualTo(keyword, context)) {
			return true
		}
		if (EQUAL.hasValue(keyword)) {
			var EObject grammarElement = context.getLastCompleteNode().getGrammarElement()
			if (isKeyword(grammarElement, SYNTAX)) {
				proposeEqualProto2(context, acceptor)
				proposeEqualProto3(context, acceptor)
			}
			return true
		}
		if (OPENING_BRACKET.hasValue(keyword)) {
			return proposeOpeningBracket(context, acceptor)
		}
		if (OPENING_CURLY_BRACKET.hasValue(keyword)) {
			var EObject model = context.getCurrentModel()
			return model instanceof Option || model instanceof ComplexValue
		}
		if (TRUE.hasValue(keyword) || FALSE.hasValue(keyword)) {
			if (isBoolProposalValid(context)) {
				proposeBooleanValues(context, acceptor)
			}
			return true
		}
		if (NAN.hasValue(keyword)) {
			if (isNanProposalValid(context)) {
				proposeAndAccept(keyword.toString(), context, acceptor)
			}
			return true
		}
		// remove keyword proposals when current node is "]". At this position we
		// only accept "default" or field options.
		return context.getCurrentNode().getText().equals(CLOSING_BRACKET.toString())
	}

	def private boolean isLastWordFromCaretPositionEqualTo(String word, ContentAssistContext context) {
		var StyledText styledText = context.getViewer().getTextWidget()
		var int valueLength = word.length()
		var int start = styledText.getCaretOffset() - valueLength
		if (start < 0) {
			return false
		}
		var String previousWord = styledText.getTextRange(start, valueLength)
		return word.equals(previousWord)
	}

	def private boolean isKeyword(EObject object, CommonKeyword keyword) {
		return object instanceof Keyword && keyword.hasValue(((object as Keyword)).getValue())
	}

	def private void proposeEqualProto2(ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		proposeAndAccept(EQUAL_PROTO2_IN_QUOTES, context, acceptor)
	}

	def private void proposeEqualProto3(ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		proposeAndAccept(EQUAL_PROTO3_IN_QUOTES, context, acceptor)
	}

	def private void proposeAndAccept(CompoundElement proposalText, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		proposeAndAccept(proposalText.toString(), context, acceptor)
	}

	def private boolean isBoolProposalValid(ContentAssistContext context) {
		var MessageField field = fieldFrom(context)
		return field !== null && messageFields.isBool(field)
	}

	def private boolean isNanProposalValid(ContentAssistContext context) {
		var MessageField field = fieldFrom(context)
		return field !== null && messageFields.isFloatingPointNumber(field)
	}

	def private MessageField fieldFrom(ContentAssistContext context) {
		var EObject model = context.getCurrentModel()
		if (model instanceof MessageField) {
			return (model as MessageField)
		}
		if (model instanceof AbstractOption) {
			var AbstractOption option = (model as AbstractOption)
			var IndexedElement source = options.rootSourceOf(option)
			if (source instanceof MessageField) {
				return (source as MessageField)
			}
		}
		return null
	}

	def private boolean proposeOpeningBracket(ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		var EObject model = context.getCurrentModel()
		if (model instanceof ComplexValue) {
			return true
		}
		if (model instanceof MessageField) {
			var MessageField field = (model as MessageField)
			var ModifierEnum modifier = field.getModifier()
			if (OPTIONAL.equals(modifier)) {
				var CompoundElement display = DEFAULT_EQUAL_IN_BRACKETS
				var int cursorPosition = display.indexOf(CLOSING_BRACKET)
				if (messageFields.isString(field)) {
					display = DEFAULT_EQUAL_STRING_IN_BRACKETS
					cursorPosition++
				}
				createAndAccept(display, cursorPosition, context, acceptor)
			}
			return true
		}
		return false
	}

	def private <T> T extractElementFromContext(ContentAssistContext context, Class<T> type) {
		var EObject model = context.getCurrentModel()
		// this is most likely a bug in Xtext:
		if (!type.isInstance(model)) {
			model = context.getPreviousModel()
		}
		if (!type.isInstance(model)) {
			return null
		}
		return type.cast(model)
	}

	def private ICompletionProposal createCompletionProposal(CompoundElement proposal, ContentAssistContext context) {
		return createCompletionProposal(proposal.toString(), context)
	}

	override void completeLiteral_Index(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var long index = literals.calculateNewIndexOf((model as Literal))
		proposeIndex(index, context, acceptor)
	}

	override void completeLiteralLink_Target(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var MessageField field = null
		if (model instanceof DefaultValueFieldOption) {
			field = model.eContainer() as MessageField
		}
		if (field === null || !messageFields.isOptional(field)) {
			return;
		}
		var Enum enumType = messageFields.enumTypeOf(field)
		if (enumType !== null) {
			proposeAndAccept(enumType, context, acceptor)
		}
	}

	override void completeMessageField_Index(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var long index = indexedElements.calculateNewIndexFor((model as MessageField))
		proposeIndex(index, context, acceptor)
	}

	def private void proposeIndex(long index, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		proposeAndAccept(valueOf(index), context, acceptor)
	}

	override void completeMessageField_Name(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var String typeName = toFirstLower(messageFields.typeNameOf((model as MessageField)))
		var int index = 1
		var String name = typeName + index
		for (EObject o : model.eContainer().eContents()) {
			if (o !== model && o instanceof MessageField) {
				var MessageField field = (o as MessageField)
				if (name.equals(field.getName())) {
					name = typeName + ({
						index = index + 1
					})
				}
			}
		}
		proposeAndAccept(name, context, acceptor)
	}

	def private void proposeAndAccept(String proposalText, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		acceptor.accept(createCompletionProposal(proposalText, context))
	}

	override protected ICompletionProposal createCompletionProposal(String proposalText, ContentAssistContext context) {
		return createCompletionProposal(proposalText, null, defaultImage(), getPriorityHelper().getDefaultPriority(),
			context.getPrefix(), context)
	}

	def private Image defaultImage() {
		return imageHelper.getImage(images.defaultImage())
	}

	override void completeDefaultValueFieldOption_Value(EObject model, Assignment assignment,
		ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		var MessageField field = null
		if (model instanceof DefaultValueFieldOption) {
			field = model.eContainer() as MessageField
		}
		if (model instanceof MessageField) {
			field = model as MessageField
		}
		if (field === null || !messageFields.isOptional(field)) {
			return;
		}
		proposeFieldValue(field, context, acceptor)
	}

	def private boolean proposePrimitiveValues(MessageField field, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		if (messageFields.isBool(field)) {
			proposeBooleanValues(context, acceptor)
			return true
		}
		if (messageFields.isString(field)) {
			proposeEmptyString(context, acceptor)
			return true
		}
		return false
	}

	def private void proposeBooleanValues(ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		var CommonKeyword[] keywords = #[FALSE, TRUE]
		proposeAndAccept(keywords, context, acceptor)
	}

	def private void proposeAndAccept(CommonKeyword[] keywords, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		for (CommonKeyword keyword : keywords) {
			proposeAndAccept(keyword.toString(), context, acceptor)
		}
	}

	def private void proposeEmptyString(ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		createAndAccept(EMPTY_STRING, 1, context, acceptor)
	}

	def private void createAndAccept(CompoundElement display, int cursorPosition, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var ICompletionProposal proposal = createCompletionProposal(display, context)
		if (proposal instanceof ConfigurableCompletionProposal) {
			var ConfigurableCompletionProposal configurable = (proposal as ConfigurableCompletionProposal)
			configurable.setCursorPosition(cursorPosition)
		}
		acceptor.accept(proposal)
	}

	override void completeOptionSource_Target(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
	}

	override void completeMessageOptionField_Target(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
	}

	override void completeExtensionOptionField_Target(EObject model, Assignment assignment,
		ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
	}

	override void complete_MessageOptionField(EObject model, RuleCall ruleCall, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
	}

	override void complete_ExtensionOptionField(EObject model, RuleCall ruleCall, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
	}

	override void completeCustomOption_Value(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		if (model instanceof CustomOption) {
			var CustomOption option = (model as CustomOption)
			var IndexedElement e = options.sourceOfLastFieldIn(option)
			if (e === null) {
				e = options.rootSourceOf(option)
			}
			if (e instanceof MessageField) {
				proposeFieldValue((e as MessageField), context, acceptor)
			}
		}
	}

	override void completeCustomFieldOption_Value(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		// TODO content assist returns "{"
		if (model instanceof CustomFieldOption) {
			// TODO check if this is the same as sourceOf
			var CustomFieldOption option = (model as CustomFieldOption)
			var IndexedElement e = options.sourceOfLastFieldIn(option)
			if (e === null) {
				e = options.rootSourceOf(option)
			}
			if (e instanceof MessageField) {
				proposeFieldValue((e as MessageField), context, acceptor)
			}
		}
	}

	def private void proposeFieldValue(MessageField field, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		if (field === null || proposePrimitiveValues(field, context, acceptor)) {
			return;
		}
		var Enum enumType = messageFields.enumTypeOf(field)
		if (enumType !== null) {
			proposeAndAccept(enumType, context, acceptor)
		}
	}

	def private void proposeAndAccept(Enum enumType, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var Image image = imageHelper.getImage(images.imageFor(LITERAL))
		for (Literal literal : getAllContentsOfType(enumType, Literal)) {
			proposeAndAccept(literal.getName(), image, context, acceptor)
		}
	}

	override void completeNormalFieldName_Target(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
	}

	override void completeExtensionFieldName_Target(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
	}

	override void complete_SimpleValueLink(EObject model, RuleCall ruleCall, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var SimpleValueField field = extractElementFromContext(context, SimpleValueField)
		if (field !== null) {
			var FieldName name = field.getName()
			if (name !== null) {
				var IndexedElement target = name.getTarget()
				if (target instanceof MessageField) {
					proposeFieldValue((target as MessageField), context, acceptor)
				}
			}
		}
	}

	def private void proposeAndAccept(String proposalText, Image image, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var ICompletionProposal proposal = createCompletionProposal(proposalText, proposalText, image, context)
		acceptor.accept(proposal)
	}

	override ICompletionProposal createCompletionProposal(String proposal, String displayString, Image image,
		ContentAssistContext contentAssistContext) {
		var StyledString styled = null
		if (displayString !== null) {
			styled = new StyledString(displayString)
		}
		var int priority = getPriorityHelper().getDefaultPriority()
		var String prefix = contentAssistContext.getPrefix()
		return createCompletionProposal(proposal, styled, image, priority, prefix, contentAssistContext)
	}
}
