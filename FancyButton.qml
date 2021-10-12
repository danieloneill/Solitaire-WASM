import QtQuick 2.7

Rectangle {
    id: fancyButton
    radius: 10
    implicitHeight: buttonLabel.implicitHeight + 20
    implicitWidth: buttonLabel.implicitWidth + 20
    height: buttonLabel.implicitHeight + 20
    width: buttonLabel.implicitWidth + 20

    property alias text: buttonLabel.text
    signal clicked()

    Text {
        id: buttonLabel
        anchors.centerIn: parent
        font.pixelSize: topContainer.width > topContainer.height ? topContainer.width * 0.033 : topContainer.width * 0.12
        font.family: ostrichSans.name
    }

    MouseArea {
        anchors.fill: parent
        onClicked: fancyButton.clicked();
    }
}
