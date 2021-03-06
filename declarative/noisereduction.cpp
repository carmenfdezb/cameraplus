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

#include "noisereduction.h"

NoiseReduction::NoiseReduction(QtCamDevice *dev, QObject *parent) :
  Capability(parent),
  m_nr(new QtCamNoiseReduction(dev, this)) {

  setCapability(m_nr);

  QObject::connect(m_nr, SIGNAL(valueChanged()), this, SIGNAL(valueChanged()));
}

NoiseReduction::~NoiseReduction() {
  if (m_nr) {
    delete m_nr;
    m_nr = 0;
  }
}


NoiseReduction::NoiseReductionMode NoiseReduction::value() {
  return m_nr ? (NoiseReductionMode)m_nr->value() : NoiseReduction::None;
}

void NoiseReduction::setValue(const NoiseReduction::NoiseReductionMode& mode) {
  if (m_nr) {
    m_nr->setValue((QtCamNoiseReduction::NoiseReductionMode)mode);
  }
}

void NoiseReduction::prepareForDeviceChange() {
  if (m_nr) {
    delete m_nr;
    m_nr = 0;
  }
}
