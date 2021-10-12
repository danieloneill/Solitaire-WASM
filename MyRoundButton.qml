import QtQuick 2.7

Item {
    id: buttonItem
    width: topContainer.width < topContainer.height ? topContainer.width * 0.15 : topContainer.height * 0.15
    height: width

    property alias source: buttonIcon.source
    signal clicked()

    Rectangle {
        anchors.fill: parent
        radius: 90
        color: 'white'
    }
    Image {
        id: buttonIcon
        anchors.fill: parent
        anchors.margins: 5
    }
    MouseArea {
        anchors.fill: parent
        onClicked: buttonItem.clicked();
    }
}
