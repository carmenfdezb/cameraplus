// -*- qml -*-

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

import QtQuick 2.0
import QtCamera 1.0
import CameraPlus 1.0

Item {
    id: mouse
    property bool reticlePressed
    property variant videoResolution
    onVideoResolutionChanged: resetReticle()

    property int cafStatus
    property int autoFocusStatus
    property Camera cam
    property bool touchMode

    // Current touch point
    property variant _touchPoint: Qt.point(mouse.width / 2, mouse.height / 2)

    // A central region.
    property real _centerX: (mouse.width - cameraStyle.focusReticleCenterRectDimension) / 2
    property real _centerY: (mouse.height - cameraStyle.focusReticleCenterRectDimension) / 2
    property real _centerDimension: cameraStyle.focusReticleCenterRectDimension

    // used to store the existing touch point before changing it when the reticle gets pressed
    property variant _initialPos

    // ROI:
    property variant primaryRoiRect: Qt.rect(0, 0, 0, 0)
    property variant roiRects
    property variant allRoiRects
    property bool roiMode: allRoiRects != null && allRoiRects.length > 0 && !touchMode && !reticlePressed && settings.faceDetectionEnabled

    onRoiModeChanged: {
        if (!roiMode) {
            resetReticle()
        }
    }

    enabled: deviceFeatures().isTouchFocusSupported

    function pressed(point) {
        _initialPos = _touchPoint
        calculateTouchPoint(point.x, point.y)
    }

    function canceled() {
        calculateTouchPoint(_initialPos.x, _initialPos.y)
    }

    function doubleClicked() {
        resetReticle()
    }

    function resetReticle() {
        calculateTouchPoint(_centerX, _centerY)
    }

    function setRegionOfInterest() {
        if (!cam) {
            // console.log("Cannot set ROI without camera object")
            return
        } else if (!touchMode && !roiMode) {
            // console.log("resetting ROI")
            if (cam.roi) {
                cam.roi.resetRegionOfInterest()
            }

            return
        }

//        console.log("Setting ROI to: " + reticle.x + "x" + reticle.y + " -> " + reticle.width + "x" + reticle.height)
        cam.roi.setRegionOfInterest(cameraPosition.toSensorCoordinates(Qt.rect(reticle.x, reticle.y, reticle.width, reticle.height), Qt.point(mouse.width / 2, mouse.height / 2)))
    }

    function calculateTouchPoint(x, y) {
        if (x >= _centerX && y >= _centerY &&
            x <= _centerX + _centerDimension &&
            y <= _centerY + _centerDimension) {
                touchMode = false
                _touchPoint = Qt.point(mouse.width / 2, mouse.height / 2)
                return
        }

        touchMode = true
        _touchPoint = Qt.point(x, y)
    }

    function predictColor(caf, autoFocusStatus) {
        if (autoFocusStatus == AutoFocus.Success) {
            return "steelblue"
        } else if (autoFocusStatus == AutoFocus.Fail) {
            return "red"
        } else if (autoFocusStatus == AutoFocus.Running) {
            return "white"
        } else if (caf == AutoFocus.Success) {
            return "steelblue"
        } else {
            return "white"
        }
    }

    Repeater {
        anchors.fill: parent
        model: roiMode ? roiRects : 0

        delegate: Rectangle {
            property variant roiRect: cameraPosition.fromSensorCoordinates(modelData, Qt.point(mouse.width / 2, mouse.height / 2))
            x: roiRect.x
            y: roiRect.y
            width: roiRect.width
            height: roiRect.height
            color: "transparent"
            border.color: "gray"
            border.width: 2
        }
    }

    FocusRectangle {
        id: reticle
        width: mouse.reticlePressed ? cameraStyle.focusReticlePressedWidth : mouse.touchMode ? cameraStyle.focusReticleTouchWidth : roiMode ? primaryRoiRect.width : cameraStyle.focusReticleNormalWidth
        height: mouse.reticlePressed ? cameraStyle.focusReticlePressedHeight : mouse.touchMode ? cameraStyle.focusReticleTouchHeight : roiMode ? primaryRoiRect.height : cameraStyle.focusReticleNormalHeight
        x: Math.min(Math.max(mouse._touchPoint.x - (width / 2), 0), mouse.width - reticle.width)
        y: Math.min(Math.max(mouse._touchPoint.y - (height / 2), 0), mouse.height - reticle.height)
        color: predictColor(cafStatus, autoFocusStatus)

        onXChanged: setRegionOfInterest()
        onYChanged: setRegionOfInterest()

        Behavior on width {
            PropertyAnimation { duration: 100 }
        }

        Behavior on height {
            PropertyAnimation { duration: 100 }
        }

    }

    Connections {
        target: cam
        onRunningChanged: resetReticle()
    }

    Connections {
        target: root
        onActivePluginChanged: resetReticle()
    }

    Connections {
        target: cameraPosition
        onApplicationOrientationAngleChanged: resetReticle()
    }

    Connections {
        target: cam.roi
        onRegionsChanged: {
            allRoiRects = regions
            // Repeater delegate will take care of transforming the rest of the rectangles.
            primaryRoiRect = cameraPosition.fromSensorCoordinates(primary, Qt.point(mouse.width / 2, mouse.height / 2))
            roiRects = rest

            if (regions.length == 0) {
                resetReticle()
                return
            }

            _touchPoint = Qt.point(primary.x + (reticle.width / 2),
                primary.y + (reticle.height / 2))
        }
    }

    /*
    // This is for debugging
    Rectangle {
        color: "blue"
        opacity: 0.2
        anchors.fill: parent
    }

    Rectangle {
        color: "red"
        opacity: 0.4
        x: _centerX
        y: _centerY
        width: _centerDimension
        height: _centerDimension
    }
    */
    Timer {
        interval: 500
        running: autoFocusStatus == AutoFocus.Running
        triggeredOnStart: true
        repeat: true
        onTriggered: reticle.visible = !reticle.visible
        onRunningChanged: reticle.visible = true
    }
}
