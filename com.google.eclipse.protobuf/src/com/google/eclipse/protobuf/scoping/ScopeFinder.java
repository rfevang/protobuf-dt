/*
 * Copyright (c) 2011 Google Inc.
 * 
 * All rights reserved. This program and the accompanying materials are made available under the terms of the Eclipse
 * Public License v1.0 which accompanies this distribution, and is available at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.google.eclipse.protobuf.scoping;

import com.google.eclipse.protobuf.protobuf.Import;
import com.google.eclipse.protobuf.protobuf.Package;

import org.eclipse.xtext.resource.IEObjectDescription;

import java.util.Collection;

/**
 * @author alruiz@google.com (Alex Ruiz)
 */
interface ScopeFinder {

  Collection<IEObjectDescription> imported(Package fromImporter, Package fromImported, Object target, Object criteria);

  Collection<IEObjectDescription> inDescriptor(Import anImport, Object criteria);

  Collection<IEObjectDescription> local(Object target, Object criteria, int level);
}