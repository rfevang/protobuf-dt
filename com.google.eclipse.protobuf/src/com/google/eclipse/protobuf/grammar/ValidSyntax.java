/*
 * Copyright (c) 2011 Google Inc.
 * 
 * All rights reserved. This program and the accompanying materials are made available under the terms of the Eclipse
 * Public License v1.0 which accompanies this distribution, and is available at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.google.eclipse.protobuf.grammar;

/**
 * @author alruiz@google.com (Alex Ruiz)
 */
public final class ValidSyntax {

  public static String proto2() {
    return "proto2";
  }

  public static boolean isProto2Syntax(String s) {
    return proto2().equals(s);
  }

  private ValidSyntax() {}
}