import QtQuick 2.7

import 'logic.js' as Logic

Rectangle {
    id: topStack

    property string laneId

    readonly property string laneType: 'tableau'

    //width: 120
    //height: 169
    width: topContainer.cardWidth
    height: topContainer.cardHeight

    radius: 5

    color: '#99aaaadd'
}
