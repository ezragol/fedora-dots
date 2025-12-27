/***************************************************************************
* Copyright (c) 2013 Abdurrahman AVCI <abdurrahmanavci@gmail.com>
* Copyright (c) 2024 Aleksei Bavshin <alebastr@fedoraproject.org>
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
* OR OTHER DEALINGS IN THE SOFTWARE.
*
***************************************************************************/

import QtQuick 2.0
import SddmComponents 2.0

import "./components"

Rectangle {
    id: container
    width: 640
    height: 480

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    Connections {
        target: sddm

        function onLoginSucceeded() {
            errorMessage.color = "steelblue"
            errorMessage.text = textConstants.loginSucceeded
        }
        function onLoginFailed() {
            password.text = ""
            errorMessage.color = "red"
            errorMessage.text = textConstants.loginFailed
        }
        function onInformationMessage(message) {
            errorMessage.color = "red"
            errorMessage.text = message
        }
    }

    Background {
        anchors.fill: parent
        source: Qt.resolvedUrl(config.background)
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            var defaultBackground = Qt.resolvedUrl(config.defaultBackground)
            if (status == Image.Error && source != defaultBackground) {
                source = defaultBackground
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        //visible: primaryScreen

        Row {
            id: mainColumn
            anchors.centerIn: parent
            width: Math.max(950, mainColumn.implicitWidth + 150)
            height: Math.max(445, mainColumn.implicitHeight + 50)

            Image {
                id: rectangle1
                anchors.left: parent.left
                width: 546; height: 442

                source: Qt.resolvedUrl("drawing.png")
                
                Column {
                    width: parent.width
                    spacing: 10
                    anchors.top: parent.top
                    anchors.topMargin: 120
                    anchors.left: parent.left

                    TextBox {
                        id: name
                        width: parent.width * 0.55; height: 50
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: userModel.lastUser
                        font.pixelSize: 30
                        font.family: "Cantarell"
                        font.bold: true
                        color: "transparent"
                        borderColor: "transparent"; hoverColor: "transparent"; focusColor: "transparent"

                        KeyNavigation.backtab: rebootButton; KeyNavigation.tab: password

                        Keys.onPressed: function (event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }

                    PasswordBox {
                        id: password
                        width: parent.width * 0.53; height: 50
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "transparent"

                        KeyNavigation.backtab: name; KeyNavigation.tab: session

                        Keys.onPressed: function (event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: 18

                        Text {
                            id: errorMessage
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: textConstants.prompt
                            font.pixelSize: 10
                            color: "white"
                        }

                        Row {
                            spacing: 4
                            anchors.horizontalCenter: parent.horizontalCenter

                            property int btnWidth: Math.max(loginButton.implicitWidth,
                                                            shutdownButton.implicitWidth,
                                                            rebootButton.implicitWidth, 85) + 8
                            Button {
                                id: loginButton
                                text: textConstants.login
                                width: parent.btnWidth

                                onClicked: sddm.login(name.text, password.text, sessionIndex)

                                KeyNavigation.backtab: layoutBox; KeyNavigation.tab: shutdownButton
                            }

                            Button {
                                id: shutdownButton
                                text: textConstants.shutdown
                                width: parent.btnWidth

                                onClicked: sddm.powerOff()

                                KeyNavigation.backtab: loginButton; KeyNavigation.tab: rebootButton
                            }

                            Button {
                                id: rebootButton
                                text: textConstants.reboot
                                width: parent.btnWidth

                                onClicked: sddm.reboot()

                                KeyNavigation.backtab: shutdownButton; KeyNavigation.tab: name
                            }
                        }
                    }
                }
            }

            Column {
                width: 400
                height: 210
                anchors.right: parent.right; anchors.top: parent.top
                anchors.rightMargin: -15
                anchors.topMargin: 40

                Clock {
                    id: clock
                    anchors.topMargin: 33
                    anchors.top: parent.top

                    color: "white"
                    timeFont.bold: true
                    timeFont.family: "Inconsolata"
                }

                Rectangle {
                    width: parent.width / 1.85; height: select.height * 0.7
                    color: "black"
                    anchors.top: parent.bottom; anchors.right: parent.right
                    anchors.topMargin: -40
                    anchors.rightMargin: 62

                    Row {
                        id: select
                        spacing: 4
                        width: parent.width * 2; height: 50
                        anchors.bottom: parent.bottom; anchors.right: parent.right
                        anchors.rightMargin: -95
                        anchors.bottomMargin: -5
                        z: 100

                        Text {
                            width: parent.width / 1.7; height: 20
                            anchors.left: parent.horizontalCenter; anchors.bottom: parent.verticalCenter
                            anchors.bottomMargin: -2
                            anchors.leftMargin: -93
                            font.pixelSize: 30
                            font.family: "Cantarell"
                            font.bold: true
                            text: "Desktop:"
                            color: "white"
                        }

                        ComboBox {
                            id: session
                            width: parent.width / 3.5; height: 50
                            anchors.right: parent.right
                            anchors.rightMargin: 50
                            font.pixelSize: 30
                            font.family: "Cantarell"
                            font.bold: true
                            borderWidth: 0
                            color: "transparent"
                            arrowColor: "transparent"
                            textColor: "white"

                            model: sessionModel
                            index: sessionModel.lastIndex

                            KeyNavigation.backtab: password; KeyNavigation.tab: layoutBox
                        }

                        Column {
                            z: 101
                            width: parent.width * 0.7
                            spacing: 4
                            anchors.bottom: parent.bottom

                            visible: keyboard.enabled && keyboard.layouts.length > 0

                            Text {
                                id: lblLayout
                                width: parent.width
                                text: textConstants.layout
                                wrapMode: TextEdit.WordWrap
                                font.bold: true
                                font.pixelSize: 12
                            }

                            LayoutBox {
                                id: layoutBox
                                width: parent.width; height: 30
                                font.pixelSize: 14

                                arrowIcon: Qt.resolvedUrl("angle-down.png")

                                KeyNavigation.backtab: session; KeyNavigation.tab: loginButton
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (name.text == "")
            name.focus = true
        else
            password.focus = true
    }
}
