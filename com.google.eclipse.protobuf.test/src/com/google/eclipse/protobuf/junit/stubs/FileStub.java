/*
 * Copyright (c) 2011 Google Inc.
 *
 * All rights reserved. This program and the accompanying materials are made available under the terms of the Eclipse
 * Public License v1.0 which accompanies this distribution, and is available at
 *
 * http://www.eclipse.org/legal/epl-v10.html
 */
package com.google.eclipse.protobuf.junit.stubs;

import static java.util.Collections.*;

import java.io.InputStream;
import java.io.Reader;
import java.net.URI;
import java.util.*;

import org.eclipse.core.resources.*;
import org.eclipse.core.runtime.*;
import org.eclipse.core.runtime.content.IContentDescription;
import org.eclipse.core.runtime.jobs.ISchedulingRule;

/**
 * @author alruiz@google.com (Alex Ruiz)
 */
public class FileStub implements IFile {

  private final Map<String, List<MarkerStub>> markersByType = new HashMap<String, List<MarkerStub>>();

  /** {@inheritDoc} */
  public void accept(IResourceProxyVisitor visitor, int memberFlags) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void accept(IResourceVisitor visitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void accept(IResourceVisitor visitor, int depth, boolean includePhantoms) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void accept(IResourceVisitor visitor, int depth, int memberFlags) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void appendContents(InputStream source, boolean force, boolean keepHistory, IProgressMonitor monitor)
      {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void appendContents(InputStream source, int updateFlags, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void clearHistory(IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public boolean contains(ISchedulingRule rule) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void copy(IPath destination, boolean force, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void copy(IPath destination, int updateFlags, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void copy(IProjectDescription description, boolean force, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void copy(IProjectDescription description, int updateFlags, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void create(InputStream source, boolean force, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void create(InputStream source, int updateFlags, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void createLink(IPath localLocation, int updateFlags, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void createLink(URI location, int updateFlags, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public IMarker createMarker(String type) {
    MarkerStub marker = new MarkerStub(type);
    addMarker(marker);
    return marker;
  }

  /** {@inheritDoc} */
  public IResourceProxy createProxy() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void delete(boolean force, boolean keepHistory, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void delete(boolean force, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void delete(int updateFlags, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void deleteMarkers(String type, boolean includeSubtypes, int depth) {
    List<MarkerStub> markers = markersByType.get(type);
    if (markers != null) markers.clear();
  }

  /** {@inheritDoc} */
  public boolean exists() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public IMarker findMarker(long id) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public IMarker[] findMarkers(String type, boolean includeSubtypes, int depth) {
    List<MarkerStub> markers = markersByType.get(type);
    if (markers == null) return new IMarker[0];
    return markers.toArray(new IMarker[markers.size()]);
  }

  /** {@inheritDoc} */
  public int findMaxProblemSeverity(String type, boolean includeSubtypes, int depth) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  @SuppressWarnings("rawtypes") public Object getAdapter(Class adapter) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public String getCharset() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public String getCharset(boolean checkImplicit) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public String getCharsetFor(Reader reader) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public IContentDescription getContentDescription() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public InputStream getContents() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public InputStream getContents(boolean force) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  @Deprecated public int getEncoding() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public String getFileExtension() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public IPath getFullPath() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public IFileState[] getHistory(IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public long getLocalTimeStamp() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public IPath getLocation() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public URI getLocationURI() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public IMarker getMarker(long id) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public long getModificationStamp() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public String getName() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public IContainer getParent() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public IPathVariableManager getPathVariableManager() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public Map<QualifiedName, String> getPersistentProperties() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public String getPersistentProperty(QualifiedName key) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public IProject getProject() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public IPath getProjectRelativePath() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public IPath getRawLocation() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public URI getRawLocationURI() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public ResourceAttributes getResourceAttributes() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public Map<QualifiedName, Object> getSessionProperties() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public Object getSessionProperty(QualifiedName key) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public int getType() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public IWorkspace getWorkspace() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public boolean isAccessible() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public boolean isConflicting(ISchedulingRule rule) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public boolean isDerived() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public boolean isDerived(int options) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public boolean isHidden() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public boolean isHidden(int options) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public boolean isLinked() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public boolean isLinked(int options) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  @Deprecated public boolean isLocal(int depth) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public boolean isPhantom() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public boolean isReadOnly() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public boolean isSynchronized(int depth) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public boolean isTeamPrivateMember() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public boolean isTeamPrivateMember(int options) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public boolean isVirtual() {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void move(IPath destination, boolean force, boolean keepHistory, IProgressMonitor monitor)
      {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void move(IPath destination, boolean force, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void move(IPath destination, int updateFlags, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void move(IProjectDescription description, boolean force, boolean keepHistory, IProgressMonitor monitor)
      {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void move(IProjectDescription description, int updateFlags, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void refreshLocal(int depth, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void revertModificationStamp(long value) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  @Deprecated public void setCharset(String newCharset) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void setCharset(String newCharset, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void setContents(IFileState source, boolean force, boolean keepHistory, IProgressMonitor monitor)
      {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void setContents(IFileState source, int updateFlags, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void setContents(InputStream source, boolean force, boolean keepHistory, IProgressMonitor monitor)
      {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void setContents(InputStream source, int updateFlags, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  @Deprecated public void setDerived(boolean isDerived) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void setDerived(boolean isDerived, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void setHidden(boolean isHidden) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  @Deprecated public void setLocal(boolean flag, int depth, IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public long setLocalTimeStamp(long value) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void setPersistentProperty(QualifiedName key, String value) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  @Deprecated public void setReadOnly(boolean readOnly) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void setResourceAttributes(ResourceAttributes attributes) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void setSessionProperty(QualifiedName key, Object value) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void setTeamPrivateMember(boolean isTeamPrivate) {
    throw new UnsupportedOperationException();
  }

  /** {@inheritDoc} */
  public void touch(IProgressMonitor monitor) {
    throw new UnsupportedOperationException();
  }

  public int markerCount(String type) {
    List<MarkerStub> markers = markersByType.get(type);
    return (markers == null) ? 0 : markers.size();
  }
  
  public List<MarkerStub> markers(String type) {
    List<MarkerStub> markers = markersByType.get(type);
    if (markers == null) return emptyList();
    return unmodifiableList(markers);
  }

  public void addMarker(MarkerStub marker) {
    String type = marker.getType();
    List<MarkerStub> markers = markersByType.get(type);
    if (markers == null) {
      markers = new ArrayList<MarkerStub>();
      markersByType.put(type, markers);
    }
    markers.add(marker);
  }
}