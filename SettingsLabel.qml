import QtQuick 2.7

Text {
    font.family: ostrichSans.name
    font.pixelSize: topContainer.width > topContainer.height ? topContainer.width * 0.025 : topContainer.width * 0.05
    font.bold: true
    style: Text.Outline
    styleColor: 'black'
    color: 'white'
}
