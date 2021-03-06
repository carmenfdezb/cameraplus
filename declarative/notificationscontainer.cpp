/*!
 * This file is part of CameraPlus.
 *
 * Copyright (C) 2012-2014 Mohammed Sameer <msameer@foolab.org>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#include "notificationscontainer.h"
#include "qtcamdevice.h"
#include "qtcamnotifications.h"
#include "sounds.h"

NotificationsContainer::NotificationsContainer(QObject *parent) :
  QObject(parent), m_dev(0), m_sounds(0) {

}

NotificationsContainer::~NotificationsContainer() {
  setDevice(0);

  QMutexLocker locker(&m_mutex);
  m_sounds = 0;
}

void NotificationsContainer::setDevice(QtCamDevice *dev) {
  if (m_dev) {
    QtCamNotifications *n = m_dev->notifications();
    QObject::disconnect(n, SIGNAL(imageCaptureStarted()), this, SLOT(imageCaptureStarted()));
    QObject::disconnect(n, SIGNAL(imageCaptureEnded()), this, SLOT(imageCaptureEnded()));
    QObject::disconnect(n, SIGNAL(videoRecordingStarted()), this, SLOT(videoRecordingStarted()));
    QObject::disconnect(n, SIGNAL(videoRecordingEnded()), this, SLOT(videoRecordingEnded()));
    QObject::disconnect(n, SIGNAL(autoFocusAcquired()), this, SLOT(autoFocusAcquired()));
    QObject::disconnect(n, SIGNAL(autoFocusFailed()), this, SLOT(autoFocusFailed()));
  }

  m_dev = dev;

  if (m_dev) {
    QtCamNotifications *n = m_dev->notifications();
    QObject::connect(n, SIGNAL(imageCaptureStarted()),
		     this, SLOT(imageCaptureStarted()), Qt::DirectConnection);
    QObject::connect(n, SIGNAL(imageCaptureEnded()),
		     this, SLOT(imageCaptureEnded()), Qt::DirectConnection);
    QObject::connect(n, SIGNAL(videoRecordingStarted()),
		     this, SLOT(videoRecordingStarted()), Qt::DirectConnection);
    QObject::connect(n, SIGNAL(videoRecordingEnded()),
		     this, SLOT(videoRecordingEnded()), Qt::DirectConnection);
    QObject::connect(n, SIGNAL(autoFocusAcquired()),
		     this, SLOT(autoFocusAcquired()), Qt::DirectConnection);
    QObject::connect(n, SIGNAL(autoFocusFailed()),
		     this, SLOT(autoFocusFailed()), Qt::DirectConnection);
  }
}

Sounds *NotificationsContainer::sounds() const {
  return m_sounds;
}

bool NotificationsContainer::setSounds(Sounds *sounds) {
  QMutexLocker lock(&m_mutex);

  if (m_sounds != sounds) {
    m_sounds = sounds;
    return true;
  }

  return false;
}

void NotificationsContainer::imageCaptureStarted() {
  QMutexLocker l(&m_mutex);

  if (m_sounds) {
    m_sounds->playImageCaptureStartedSound();
  }
}

void NotificationsContainer::imageCaptureEnded() {
  QMutexLocker l(&m_mutex);

  if (m_sounds) {
    m_sounds->playImageCaptureEndedSound();
  }
}

void NotificationsContainer::videoRecordingStarted() {
  QMutexLocker l(&m_mutex);

  if (m_sounds) {
    m_sounds->playVideoRecordingStartedSound();
  }
}

void NotificationsContainer::videoRecordingEnded() {
  QMutexLocker l(&m_mutex);

  if (m_sounds) {
    m_sounds->playVideoRecordingEndedSound();
  }
}

void NotificationsContainer::autoFocusAcquired() {
  QMutexLocker l(&m_mutex);

  if (m_sounds) {
    m_sounds->playAutoFocusAcquiredSound();
  }
}

void NotificationsContainer::autoFocusFailed() {
  QMutexLocker l(&m_mutex);

  if (m_sounds) {
    m_sounds->playAutoFocusFailedSound();
  }
}
