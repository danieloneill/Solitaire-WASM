import QtQuick 2.7

Rectangle {
    id: cardContainer

    width: topContainer.cardWidth
    height: topContainer.cardHeight

    //layer.enabled: true
    //layer.samples: 4

    color: 'transparent'
    radius: 5

    property string laneId
    property bool faceDown: true
    property int value: 0
    property string valueLabel: 'A'
    property string suitCode: 'H'
    property string suitSymbol: suitCode == 'D' ? '♦' : (suitCode == 'H' ? '♥' : (suitCode == 'S' ? '♤' : (suitCode == 'C' ? '♣' : '?')))
    property string suitName: suitCode == 'D' ? 'diamond' : (suitCode == 'H' ? 'heart' : (suitCode == 'S' ? 'spade' : (suitCode == 'C' ? 'club' : '?')))
    property string suitColour: suitCode == 'D' ? '#a31919' : (suitCode == 'H' ? '#a31919' : (suitCode == 'S' ? 'black' : (suitCode == 'C' ? 'black' : '?')))

    signal clicked(variant which);
    signal dropped(variant which, real x, real y);
    signal dragging(variant which);
    signal moveComplete(variant which);

    property real origX
    property real origY
    property real origZ
    property variant childCards: []

    function resetPosition()
    {
        //origZ = cardContainer.z;
        cardContainer.moveTo(origX, origY, 160+cardContainer.z, true);

        if( !childCards || childCards.length == 0 )
            return;
        
        for( var n=0; n < childCards.length; n++ )
            childCards[n].resetPosition();

        childCards = [];
    }

    function warpTo(nx, ny)
    {
        x = nx;
        y = ny;
        origX = x;
        origY = y;
        moveAnimator.toX = nx;
        moveAnimator.toY = ny;
    }

    function wiggle()
    {
        console.log("Wiggling card.");
        wiggleAnimator.running = true;
    }

    function moveTo(nx, ny, nz, invalidate)
    {
        if( !invalidate && nx == moveAnimator.toX && ny == moveAnimator.toY )
            return;

        cardContainer.visible = true;

        if( moveAnimator.running )
            moveAnimator.running = false;
/*
        origX = cardContainer.x;
        origY = cardContainer.y;
        origZ = cardContainer.z;
*/

        cardContainer.z = nz; // This is reset to origZ after animation.
        moveAnimator.fromX = cardContainer.x;
        moveAnimator.toX = nx;
        moveAnimator.fromY = cardContainer.y;
        moveAnimator.toY = ny;
        moveAnimator.running = true;
    }

    function flipUp(immediate) {
        if( !faceDown ) return;

        //topContainer.playClip("flip");

        if( immediate || ""+settings.value("effects", "true") != "true" )
        {
            faceRotator.angle = 0;
            faceDown = false;
            return;
        }

        flipDownAnimator.running = false;
        flipUpAnimator.start();
        faceDown = false;
    }
    function flipDown(immediate) {
        if( faceDown ) return;

        //topContainer.playClip("flip");

        if( immediate || ""+settings.value("effects", "true") != "true" )
        {
            faceRotator.angle = 180;
            faceDown = true;
            return;
        }

        flipUpAnimator.running = false;
        flipDownAnimator.start();
        faceDown = true;
    }

    SequentialAnimation {
        id: wiggleAnimator

        PropertyAnimation {
            from: 0
            to: -5
            target: cardContainer
            property: 'rotation'
            duration: 40
            easing {
                type: Easing.OutElastic
                amplitude: 6.5
                period: 6.25
            }
        }
        SequentialAnimation {
            loops: 2
            PropertyAnimation {
                from: -5
                to: 5
                target: cardContainer
                property: 'rotation'
                duration: 80
                easing {
                    type: Easing.OutElastic
                    amplitude: 8.0
                    period: 12.5
                }
            }
            PropertyAnimation {
                from: 5
                to: -5
                target: cardContainer
                property: 'rotation'
                duration: 80
                easing {
                    type: Easing.OutElastic
                    amplitude: 8.0
                    period: 12.5
                }
            }
        }
        PropertyAnimation {
            from: -5
            to: 0
            target: cardContainer
            property: 'rotation'
            duration: 40
            easing {
                type: Easing.OutElastic
                amplitude: 6.5
                period: 6.25
            }
        }
    }

    SequentialAnimation {
        id: moveAnimator

        property real fromX
        property real toX
        property real fromY
        property real toY

        ParallelAnimation {
            NumberAnimation {
                target: cardContainer
                from: moveAnimator.fromX
                to: moveAnimator.toX
                property: 'x'
                duration: 150
            }
            NumberAnimation {
                target: cardContainer
                from: moveAnimator.fromY
                to: moveAnimator.toY
                property: 'y'
                duration: 150
            }
        }

        PropertyAction {
            target: cardContainer
            property: 'origX'
            value: cardContainer.x
        }
        PropertyAction {
            target: cardContainer
            property: 'origY'
            value: cardContainer.y
        }
        PropertyAction {
            target: cardContainer
            property: 'z'
            value: cardContainer.origZ
        }
        PropertyAction {
            target: cardContainer
            property: 'childCards'
            value: []
        }
        ScriptAction {
            script: cardContainer.moveComplete(cardContainer);
        }
    }

    SequentialAnimation {
        id: flipUpAnimator
        PropertyAnimation {
            target: faceRotator
            property: 'angle'
            from: 180
            to: 0
            duration: 150
        }
        PropertyAction {
            target: cardContainer
            property: 'faceDown'
            value: false
        }
    }

    SequentialAnimation {
        id: flipDownAnimator
        PropertyAnimation {
            target: faceRotator
            property: 'angle'
            from: 0
            to: 180
            duration: 150
        }
        PropertyAction {
            target: cardContainer
            property: 'faceDown'
            value: true
        }
    }

    Rotation {
        id: faceRotator
        angle: 180
        axis {
            x: 0
            y: 1
            z: 0
        }
        origin {
            x: face.width * 0.5
            y: face.height * 0.5
        }
    }
/*
    Image {
        id: face
        transform: faceRotator
        visible: faceRotator.angle < 180 || faceRotator.angle > 270
        anchors.fill: parent
        source: 'cards/'+valueLabel+suitCode+'.png'
        fillMode: Image.PreserveAspectCrop
        //sourceSize.width: parent.width
        //sourceSize.height: parent.height
        smooth: true
    }
*/
    Rectangle {
        id: face
        border {
            width: 1
            color: 'black'
        }

        Text {
            font.family: ostrichSans.name
            color: suitColour
            text: valueLabel
            font.pixelSize: topContainer.isPortrait ? parent.height * 0.35 : parent.height * 0.15
            anchors {
                left: parent.left
                top: parent.top
                topMargin: topContainer.isPortrait ? 0 : 0
                leftMargin: topContainer.isPortrait ? 3 : 5
            }
        }

        Image {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 5
            height: parent.height * 0.5
            width: parent.width * 0.5
            source: suitName+'.png'
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Image {
            anchors {
                top: parent.top
                right: parent.right
                margins: 5
            }

            height: topContainer.isPortrait ? parent.height * 0.2 : parent.height * 0.075
            width: topContainer.isPortrait ? parent.height * 0.25 : parent.width * 0.075
            source: suitName+'.png'
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        radius: 5
        transform: faceRotator
        visible: faceRotator.angle < 180 || faceRotator.angle > 270
        anchors.fill: parent
    }

    Rotation {
        id: backRotator
        angle: faceRotator.angle - 180
        axis {
            x: 0
            y: 1
            z: 0
        }
        origin {
            x: face.width * 0.5
            y: face.height * 0.5
        }
    }

    Rectangle {
        id: back
        transform: backRotator
        visible: faceRotator.angle > 90 && faceRotator.angle <= 270
        anchors.fill: parent
        radius: 5
        border {
            width: 1
            color: 'black'
        }
        color: 'white'
/*
        OpacityMask {
            anchors.fill: parent
            anchors.margins: 0
            source: backImage
            maskSource: backClipper
        }
*/
        Image {
            id: backImage
//            visible: false
            anchors.fill: parent
            anchors.margins: settings.cardback == 'Back.png' ? 0 : 2
            source: settings.cardback
            //fillMode: Image.PreserveAspectCrop
            fillMode: settings.cardback == 'Back.png' ? Image.Stretch : Image.PreserveAspectCrop
            sourceSize.width: width
            sourceSize.height: height
        }
/*
        Rectangle {
            id: backClipper
            visible: false
            anchors.fill: parent
            anchors.margins: settings.cardback == 'Back.png' ? 0 : 22
            radius: 5
            color: 'black'
        }
*/
    }

    MouseArea {
        id: mouseBox
        anchors.fill: parent

        property bool isDragging: false
        property real oldX
        property real oldY

        onPressed: {
            oldX = mouseX;
            oldY = mouseY;
        }

        onMouseXChanged: function(mouse) {
            if( Qt.platform.os == 'wasm' )
            {
                // Dragging doesn't work properly in WASM, at least on FF.
                // Click-to-place will have to do until 6.4 I suspect.
                // FIXME: Find what causes this behavour and report to Qt JIRA
                return;
            }

            if( !isDragging && !moveAnimator.running && ( mouseX > oldX + 10 || mouseX < oldX - 10 ) )
            {
                isDragging = true;
                cardContainer.dragging(cardContainer);
            }
            else if( isDragging )
            {
                var mp = topContainer.mapFromItem(mouseBox, mouseX-oldX, mouseY-oldY);
                cardContainer.x = mp.x;
                if( cardContainer.childCards && cardContainer.childCards.length > 0 )
                {
                    for( var j=0; j < cardContainer.childCards.length; j++ )
                        cardContainer.childCards[j].x = cardContainer.x;
                }
            }
            mouse.accepted = true;
        }

        onMouseYChanged: function(mouse) {
            if( Qt.platform.os == 'wasm' )
            {
                // Dragging doesn't work properly in WASM, at least on FF.
                // Click-to-place will have to do until 6.4 I suspect.
                // FIXME: Find what causes this behavour and report to Qt JIRA
                return;
            }

            if( !isDragging && !moveAnimator.running && ( mouseY > oldY + 10 || mouseY < oldY - 10 ) )
            {
                isDragging = true;
                cardContainer.dragging(cardContainer);
            }
            else if( isDragging )
            {
                var mp = topContainer.mapFromItem(mouseBox, mouseX-oldX, mouseY-oldY);
                cardContainer.y = mp.y;
                if( cardContainer.childCards && cardContainer.childCards.length > 0 )
                {
                    for( var j=0; j < cardContainer.childCards.length; j++ )
                        cardContainer.childCards[j].y = cardContainer.y + topContainer.cardSpacing + (topContainer.cardSpacing*j);
                }
            }
            mouse.accepted = true;
        }

        onReleased: function(mouse) {
            if( isDragging )
            {
                //console.log('Was dragging.');
                var dp = topContainer.mapFromItem(mouseBox, mouseX, mouseY);
                cardContainer.dropped(cardContainer, dp.x, dp.y);
                mouse.accepted = true;
            }
            else
            {
                //console.log("Wasn't dragging");
                if( !moveAnimator.running && !flipDownAnimator.running && !flipUpAnimator.running )
                {
                    cardContainer.clicked(cardContainer);
                    mouse.accepted = true;
                }
            }

            isDragging = false;

            oldX = -1;
            oldY = -1;
        }
    }
/*
    Text {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 5
        }
        text: valueLabel + ' ' + suitSymbol
        font.pointSize: 6
    }
    */
}
