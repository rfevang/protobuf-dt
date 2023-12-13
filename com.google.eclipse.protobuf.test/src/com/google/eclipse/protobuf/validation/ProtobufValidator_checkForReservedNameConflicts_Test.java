/*
 * Copyright (c) 2015 Google Inc.
 *
 * All rights reserved. This program and the accompanying materials are made available under the terms of the Eclipse
 * Public License v1.0 which accompanies this distribution, and is available at
 *
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.google.eclipse.protobuf.validation;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.verifyZeroInteractions;
import static com.google.eclipse.protobuf.junit.core.UnitTestModule.unitTestModule;
import static com.google.eclipse.protobuf.junit.core.XtextRule.overrideRuntimeModuleWith;

import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;

import com.google.eclipse.protobuf.junit.core.XtextRule;
import com.google.eclipse.protobuf.protobuf.Group;
import com.google.eclipse.protobuf.protobuf.Message;
import com.google.eclipse.protobuf.protobuf.MessageField;
import com.google.eclipse.protobuf.protobuf.ProtobufPackage;
import com.google.eclipse.protobuf.protobuf.StringLiteral;
import com.google.inject.Inject;

public class ProtobufValidator_checkForReservedNameConflicts_Test {
  @Rule public XtextRule xtext = overrideRuntimeModuleWith(unitTestModule());

  @Inject private ProtobufValidator validator;
  private ValidationMessageAcceptor messageAcceptor;

  @Before public void setUp() {
    messageAcceptor = mock(ValidationMessageAcceptor.class);
    validator.setMessageAcceptor(messageAcceptor);
  }

  // syntax = "proto2";
  //
  // message Person {
  //   reserved "foo", "bar";
  //   reserved "foo", 'b' 'a' 'r';
  // }
  @Test public void should_error_on_conflict_between_reserved_and_reserved() {
    validator.checkForReservedNameConflicts(xtext.findFirst(Message.class));
    List<StringLiteral> stringLiterals = xtext.findAll(StringLiteral.class);
    verifyError("Name \"foo\" conflicts with reserved \"foo\".", stringLiterals.get(3));
    verifyError("Name \"bar\" conflicts with reserved \"bar\".", stringLiterals.get(4));
  }

  // syntax = "proto2";
  //
  // message Person {
  //   reserved "foo", "bar", "baz";
  //   optional bool foo = 1;
  //   group bar = 2 {
  //     optional bool baz = 3;
  //   }
  // }
  @Test public void should_error_on_conflict_between_reserved_and_indexed_element() {
    validator.checkForReservedNameConflicts(xtext.findFirst(Message.class));
    verifyError(
        "Name \"foo\" conflicts with reserved \"foo\".",
        xtext.findAll(MessageField.class).get(0),
        ProtobufPackage.Literals.MESSAGE_FIELD__NAME);
    verifyError(
        "Name \"bar\" conflicts with reserved \"bar\".",
        xtext.findAll(Group.class).get(0),
        ProtobufPackage.Literals.COMPLEX_TYPE__NAME);
    verifyError(
        "Name \"baz\" conflicts with reserved \"baz\".",
        xtext.findAll(MessageField.class).get(1),
        ProtobufPackage.Literals.MESSAGE_FIELD__NAME);
  }

  // syntax = "proto2";
  //
  // message Car {
  // }
  //
  // message Person {
  //   reserved "owner";
  //   optional bool passenger = 1;
  //   extend Car {
  //     optional Person owner = 1;
  //     repeated Person passenger = 2;
  //   }
  // }
  @Test public void should_not_find_conflict_with_nested_extension() {
    validator.checkForReservedNameConflicts(xtext.findFirst(Message.class));
    verifyZeroInteractions(messageAcceptor);
  }

  // syntax = "proto2";
  //
  // message Person {
  //   group foo = 10 {
  //     reserved "in_same_group", "outside_group", "in_other_group";
  //     optional bool in_same_group = 1;
  //   }
  //   optional bool outside_group = 2;
  //   group bar = 20 {
  //     optional bool in_other_group = 3;
  //   }
  // }
  @Test public void should_error_on_conflict_with_reserved_in_group() {
    validator.checkForReservedNameConflicts(xtext.findFirst(Message.class));
    List<MessageField> messageFields = xtext.findAll(MessageField.class);
    verifyError(
        "Name \"in_same_group\" conflicts with reserved \"in_same_group\".",
        messageFields.get(0),
        ProtobufPackage.Literals.MESSAGE_FIELD__NAME);
    verifyError(
        "Name \"outside_group\" conflicts with reserved \"outside_group\".",
        messageFields.get(1),
        ProtobufPackage.Literals.MESSAGE_FIELD__NAME);
    verifyError(
        "Name \"in_other_group\" conflicts with reserved \"in_other_group\".",
        messageFields.get(2),
        ProtobufPackage.Literals.MESSAGE_FIELD__NAME);
    verifyNoMoreInteractions(messageAcceptor);
  }

  private void verifyError(String message, EObject errorSource) {
    verifyError(message, errorSource, null);
  }

  private void verifyError(String message, EObject errorSource, EStructuralFeature errorFeature) {
    verify(messageAcceptor).acceptError(message, errorSource, errorFeature, -1, null);
  }
}
