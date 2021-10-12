import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Particles 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import "logic.js" as Logic

Item {
    id: topWindow
    width: 960
    height: 540
    visible: true
    //title: qsTr("Solitaire")

    Item {
        id: settings
        property string background: 'background.jpg'
        property string cardback: 'Back.png'
        property variant cardmaps: []
        property real volume: 1.0
        property string muted: 'false'
        property string unlimited: 'true'
        property string effects: 'true'
        // background volume muted unlimited effects cardback cardmaps
        function setValue(ikey, inval) {
            if( 'background' == ikey ) background=inval;
            else if( 'cardback' == ikey ) cardback=inval;
            else if( 'cardmaps' == ikey ) cardmaps=inval;
            else if( 'volume' == ikey ) volume=inval;
            else if( 'muted' == ikey ) muted=''+inval;
            else if( 'unlimited' == ikey ) unlimited=''+inval;
            else if( 'effects' == ikey ) effects=''+inval;
        }
        function value(ikey, idefault) {
            if( 'background' == ikey ) return background ? background : idefault;
            else if( 'cardback' == ikey ) return cardback ? cardback : idefault;
            else if( 'cardmaps' == ikey ) return cardmaps ? cardmaps : idefault;
            else if( 'volume' == ikey ) return volume != undefined ? volume : idefault;
            else if( 'muted' == ikey ) return muted != undefined ? muted : idefault;
            else if( 'unlimited' == ikey ) return unlimited != undefined ? unlimited : idefault;
            else if( 'effects' == ikey ) return effects != undefined ? effects : idefault;
            return idefault;
        }
    }

/** Requires QtMultimedia, which (apparently) isn't supported on Qt 6.3 in WebAssembly: **
    SoundEffect {
        id: shuffle1
        source: "PlayingCards_Shuffle_01.wav"
        volume: topContainer.volume
    }
    SoundEffect {
        id: shuffle2
        source: "PlayingCards_Shuffle_02.wav"
        volume: topContainer.volume
    }
    SoundEffect {
        id: shuffle3
        source: "PlayingCards_Shuffle_03.wav"
        volume: topContainer.volume
    }

    SoundEffect {
        id: deal1
        source: "PlayingCards_DealFlip_02.wav"
        volume: topContainer.volume
    }
    SoundEffect {
        id: deal2
        source: "PlayingCards_DealFlip_03.wav"
        volume: topContainer.volume
    }
    SoundEffect {
        id: deal3
        source: "PlayingCards_DealFlip_04.wav"
        volume: topContainer.volume
    }
    SoundEffect {
        id: deal4
        source: "PlayingCards_DealFlip_05.wav"
        volume: topContainer.volume
    }
    SoundEffect {
        id: deal5
        source: "PlayingCards_DealFlip_06.wav"
        volume: topContainer.volume
    }
    SoundEffect {
        id: deal6
        source: "PlayingCards_DealFlip_07.wav"
        volume: topContainer.volume
    }

    SoundEffect {
        id: slide1
        source: "PlayingCards_Slide_01.wav"
        volume: topContainer.volume
    }
    SoundEffect {
        id: slide2
        source: "PlayingCards_Slide_02.wav"
        volume: topContainer.volume
    }
    SoundEffect {
        id: slide3
        source: "PlayingCards_Slide_03.wav"
        volume: topContainer.volume
    }
    SoundEffect {
        id: slide4
        source: "PlayingCards_Slide_04.wav"
        volume: topContainer.volume
    }

    SoundEffect {
        id: victory
        source: "Victory Bells.wav"
        volume: topContainer.volume
    }
*/

    FontLoader {
        id: ostrichSans
        source: 'OstrichSans-Heavy.otf'
    }
    FontLoader {
        id: lobster
        source: 'Lobster 1.4.otf'
    }

    Image {
        id: bgImage
        anchors.fill: parent
        source: settings.value('background', 'background.jpg')
        fillMode: Image.PreserveAspectCrop
    }

    Item {
        id: topContainer
        anchors.fill: parent

        onWidthChanged: Logic.areaResized();
        onHeightChanged: Logic.areaResized();
        property bool canSolve: false

        property bool isPortrait: topContainer.width < topContainer.height
        property int cardSpacing: topContainer.width > topContainer.height ? cardHeight * 0.18 : cardHeight * 0.4
        property int cardWidth: topContainer.width * 0.1075
        property int cardHeight: topContainer.width < topContainer.height ? cardWidth / 0.71 : cardWidth * 1.10
        property real volume: settings.volume
        property int redeals: 3

        function playClip(name)
        {
            return; // Not supported in Qt 6.4 WebAssembly
/*
            if( ""+settings.value('muted', 'false') == "true" )
            {
                //console.log('I am muted!');
                return;
            }
            //console.log('I am at: '+volume);

            if( 'victory' == name )
                return victory.play();

            var rand = Math.random();
            if( 'slide' == name )
            {
                var slot = parseInt(rand * 4);
                if( 0 == slot )
                    slide1.play();
                else if( 1 == slot )
                    slide2.play();
                else if( 2 == slot )
                    slide3.play();
                else if( 3 == slot )
                    slide4.play();
                else
                    console.log("Got slide slot 5");
            }
            else if( 'flip' == name )
            {
                var slot = parseInt(rand * 6);
                if( 0 == slot )
                    deal1.play();
                else if( 1 == slot )
                    deal2.play();
                else if( 2 == slot )
                    deal3.play();
                else if( 3 == slot )
                    deal4.play();
                else if( 4 == slot )
                    deal5.play();
                else if( 5 == slot )
                    deal6.play();
                else
                    console.log("Got flip slot 7");
            }
            else if( 'shuffle' == name )
            {
                var slot = parseInt(rand * 3);
                if( 0 == slot )
                    shuffle1.play();
                else if( 1 == slot )
                    shuffle2.play();
                else if( 2 == slot )
                    shuffle3.play();
                else
                    console.log("Got shuffle slot 4");
            }
*/
        }

        FlatStack {
            id: bankLane // AKA Foundation, but that's too long.
            z: 1
            anchors {
                right: parent.right
                top: parent.top
                margins: 5
            }
            laneId: 'bank'

            MouseArea {
                anchors.fill: parent
                onClicked: function(mouse) {
                    mouse.accepted = true;
                    Logic.bankClicked();
                }
            }
        }

        Text {
            id: redealText
            visible: (""+settings.value("unlimited", "true") == "false")
            anchors {
                top: bankLane.bottom
                horizontalCenter: bankLane.horizontalCenter
                topMargin: 5
            }
            text: "Redeals: "+topContainer.redeals
            font.family: ostrichSans.name
            font.pointSize: 14
            font.bold: true
            style: Text.Outline
            styleColor: 'black'
            color: 'white'
        }

        FlatStack {
            id: wasteLane
            z: 1
            anchors {
                right: bankLane.left
                top: parent.top
                margins: 5
            }
            laneId: 'waste'

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = true;
                    Logic.wasteClicked();
                }
            }
        }

        // Ace slots:
        Item {
            id: aceRow
            anchors {
                top: parent.top
                left: parent.left
                right: wasteLane.left
                //bottom: tableauRow.top
                topMargin: 5
            }
            height: childrenRect.height + 5

            Row {
                //height: childrenRect.height
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                FlatStack {
                    id: aceLane1
                    z: 1
                    laneId: 'ace1'
                }
                FlatStack {
                    id: aceLane2
                    z: 1
                    laneId: 'ace2'
                }
                FlatStack {
                    id: aceLane3
                    z: 1
                    laneId: 'ace3'
                }
                FlatStack {
                    id: aceLane4
                    z: 1
                    laneId: 'ace4'
                }
            }
        }

        // Tableau slots:
        Item {
            id: tableauRow
            anchors {
                top: aceRow.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 5
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5

                Tableau {
                    id: lane1
                    z: 1
                    laneId: 'lane1'
                }
                Tableau {
                    id: lane2
                    z: 1
                    laneId: 'lane2'
                }
                Tableau {
                    id: lane3
                    z: 1
                    laneId: 'lane3'
                }
                Tableau {
                    id: lane4
                    z: 1
                    laneId: 'lane4'
                }
                Tableau {
                    id: lane5
                    z: 1
                    laneId: 'lane5'
                }
                Tableau {
                    id: lane6
                    z: 1
                    laneId: 'lane6'
                }
                Tableau {
                    id: lane7
                    z: 1
                    laneId: 'lane7'
                }
            }
        }
    }

    Component.onCompleted: {
        Logic.init();
    }

    Rectangle {
        id: menuBackdrop
        anchors.fill: parent
        visible: opacity > 0
        enabled: opacity > 0
        opacity: 0
        color: '#77000000'

        Behavior on opacity {
            PropertyAnimation { duration: 250 }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: menuRect.toggleMenu();
        }
    }

    Rectangle {
        id: menuRect
        anchors {
            bottom: menuButtonItem.top
            left: parent.left
            leftMargin: 10
        }
        width: childrenRect.width + 20
        height: 0
        visible: height > 0
        clip: true

        radius: 10
        color: 'white'

        Behavior on height {
            PropertyAnimation {
                duration: 250
                easing {
                    amplitude: 2.0
                    period: 1.5
                    type: Easing.OutElastic
                }
            }
        }

        Column {
            id: menuColumn
            anchors {
                top: parent.top
                left: parent.left
                margins: 10
            }
            spacing: 5

            property real lolHeight: 25 + (newGameButton.implicitHeight * 3)

            FancyButton {
                id: newGameButton
                visible: !victoryScreen.visible
                text: qsTr('New Game');
                onClicked: {
                    menuRect.toggleMenu();
                    confirmNewGameScreen.opacity = 1;
                }
                width: implicitWidth > settingsButton.implicitWidth ? implicitWidth : settingsButton.implicitWidth
            }

            Rectangle { color: 'black'; height: 1; width: newGameButton.width }

            FancyButton {
                id: settingsButton
                visible: !victoryScreen.visible
                text: qsTr('Settings');
                onClicked: {
                    menuRect.toggleMenu();
                    configMenu.open();
                }
                width: implicitWidth > newGameButton.implicitWidth ? implicitWidth : newGameButton.implicitWidth
            }

            Rectangle { color: 'black'; height: 1; width: newGameButton.width }

            FancyButton {
                id: aboutButton
                visible: !victoryScreen.visible
                text: qsTr('About');
                onClicked: {
                    menuRect.toggleMenu();
                    aboutScreen.open();
                }
                width: implicitWidth > settingsButton.implicitWidth ? implicitWidth : settingsButton.implicitWidth
            }
        }

        function toggleMenu() {
            //console.log('Menu..');
            if( menuRect.height == 0 )
            {
                menuBackdrop.opacity = 1;
                menuRect.height = menuColumn.lolHeight + 20;
            } else {
                menuBackdrop.opacity = 0;
                menuRect.height = 0;
            }
        }
    }

    MyRoundButton {
        id: menuButtonItem
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 10
        }
        source: 'open-menu-symbolic.png'
        onClicked: menuRect.toggleMenu();
    }

    MyRoundButton {
        id: undoButtonItem
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 10
        }
        source: 'edit-undo-symbolic.png'
        onClicked: Logic.restoreState(true);
    }

    FancyButton {
        visible: topContainer.canSolve && !victoryScreen.visible
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            margins: 10
        }
        //width: height * 1.5
        text: qsTr('Solve');
        onClicked: Logic.startSolveQueue();
    }

    MouseArea {
        anchors.fill: parent
        enabled: configMenu.opacity >= 1
        onClicked: {
            configMenu.close();
        }
    }

    Rectangle {
        id: configMenu
        anchors.centerIn: parent
        width: configGrid.width + 20
        height: configGrid.height + 30
        radius: 10

        visible: opacity > 0
        enabled: opacity > 0
        opacity: 0
        color: '#dd000000'

        MouseArea {
            anchors.fill: parent
        }

        Behavior on opacity {
            PropertyAnimation { duration: 250 }
        }

        clip: true

        GridLayout {
            anchors.centerIn: parent
            id: configGrid
            columnSpacing: 5
            rowSpacing: 3
            columns: 2
            //height: childrenRect.height

            SettingsLabel {
                text: qsTr('Volume:')
            }

            Slider {
                Layout.fillWidth: false
                width: configGrid.width * 0.20
                live: false
                from: 0
                to: 1
                value: settings.value("volume", 1)
                onValueChanged: {
                    topContainer.volume = value;
                    settings.setValue("volume", value);
                }
            }

            SettingsLabel {
                text: qsTr('Mute:')
            }

            CheckBox {
                id: cbMuted
                checked: ""+settings.value("muted", "false") == "true"
            }

            SettingsLabel {
                text: qsTr('Unlimited Draws:')
            }

            CheckBox {
                id: cbUnlimited
                checked: ""+settings.value("unlimited", "true") == "true"
            }

            SettingsLabel {
                text: qsTr('3D Effects:')
            }

            CheckBox {
                id: cbEffects
                checked: ""+settings.value("effects", "true") == "true"
            }

            SettingsLabel {
                visible: false
                text: qsTr('Backdrop:')
            }
            Row {
                visible: false // This doesn't work on Ubuntu Touch
                spacing: 5
                FancyButton {
                    id: selectBGButton
                    property string origURL
                    text: qsTr('Select...')
                    onClicked: {
                        selectBG.open();
                    }
                }
                FancyButton {
                    text: qsTr('Clear')
                    onClicked: {
                        selectBGButton.origURL = 'background.jpg';
                        selectBG.bgpath = 'background.jpg';
                        bgImage.source = 'background.jpg';
                    }
                }
            }

            Row {
                Layout.alignment: Qt.AlignHCenter
                Layout.columnSpan: 2
                //height: childrenRect.height
                spacing: 20
                FancyButton {
                    text: qsTr('Save')
                    onClicked: configMenu.save();
                }
                FancyButton {
                    text: qsTr('Cancel')
                    onClicked: configMenu.close();
                }
            }
        }

        function open() {
            cbMuted.checked = ""+settings.value("muted", "false") == "true";
            cbEffects.checked = ""+settings.value("effects", "true") == "true";
            cbUnlimited.checked = ""+settings.value("unlimited", "true") == "true";
            selectBG.bgpath = settings.value("background", "background.jpg");
            selectCB.cbpath = settings.value("cardback", "Back.png");
            selectBGButton.origURL = selectBG.bgpath;
            opacity = 1;
        }

        function close() {
            configMenu.opacity = 0;
            selectBG.bgpath = selectBGButton.origURL;
            bgImage.source = selectBGButton.origURL;
        }

        function save() {
            console.log("Save settings.");
            settings.setValue("muted", cbMuted.checked);
            settings.setValue("effects", cbEffects.checked);
            settings.setValue("unlimited", cbUnlimited.checked);
            settings.setValue("background", selectBG.bgpath);
            settings.setValue("cardback", selectCB.cbpath);

            //topContainer.redeals = 3;
            redealText.visible = !cbUnlimited.checked;

            configMenu.opacity = 0;
        }
    }

    Rectangle {
        id: aboutScreen
        anchors.centerIn: parent
        width: parent.width * 0.9
        height: parent.height * 0.9
        radius: 10

        visible: opacity > 0
        enabled: opacity > 0
        opacity: 0
        color: '#dd000000'

        Behavior on opacity {
            PropertyAnimation { duration: 250 }
        }

        MouseArea {
            anchors.fill: parent
        }

        Flickable {
            id: textFlicker
            clip: true
            anchors {
                fill: parent
                topMargin: 160
                leftMargin: 30
                bottomMargin: 30
                rightMargin: 30
            }
            contentHeight: aboutContents.height
            contentWidth: aboutContents.width

            flickableDirection: Flickable.VerticalFlick

            TextEdit {
                id: aboutContents
                width: textFlicker.width - 40
                color: 'white'
                font.pixelSize: topContainer.height * 0.02

                readOnly: true
                textFormat: TextEdit.RichText
                wrapMode: Text.Wrap
                text: "Loading..."

                onLinkActivated: {
                    Qt.openUrlExternally(link);
                }

                Component.onCompleted: {
                    try {
                        aboutScreen.getContents('about.html', function(cont) {
                            aboutContents.text = cont;
                        });
                    } catch(e) {
                        // Probably in WASM:
                        console.log("Error loading about.html: "+e);
                    }
                }
            }
        }

        function getContents(url, cb)
        {
            var doc = new XMLHttpRequest();
            doc.onreadystatechange = function() {
                if (doc.readyState == XMLHttpRequest.DONE) {
                    var contents = doc.responseText;
                    cb(contents);
                }
            }

            doc.open("GET", url);
            doc.send();
        }

        Image {
            anchors {
                top: parent.top
                topMargin: -10
                horizontalCenter: parent.horizontalCenter
            }

            width: 240
            height: 160
            source: 'victory.png'
            fillMode: Image.PreserveAspectFit

            Text {
                text: qsTr('Solitaire')
                anchors {
                    verticalCenterOffset: 35
                    centerIn: parent
                }
                font.pixelSize: 20
                font.bold: true
                font.family: lobster.name
                style: Text.Outline
                styleColor: "black"
                color: 'white'
            }
        }

        function open() {
            opacity = 1;
        }

        function close() {
            opacity = 0;
        }

        MyRoundButton {
            id: closeAboutButton
            anchors {
                left: aboutScreen.left
                top: aboutScreen.top
                margins: 0 - (closeAboutButton.width * 0.5)
            }
            source: 'window-close-symbolic.png'
            onClicked: aboutScreen.close();
        }
    }

    Rectangle {
        id: confirmNewGameScreen
        anchors.fill: parent
        visible: opacity > 0
        enabled: opacity > 0
        opacity: 0
        color: '#77000000'

        Behavior on opacity {
            PropertyAnimation { duration: 250 }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                confirmNewGameScreen.opacity = 0;
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 10
            SettingsLabel {
                text: qsTr('Are you sure you want to start over?')
            }
            Row {
                spacing: 10
                FancyButton {
                    text: qsTr('Confirm')
                    onClicked: {
                        confirmNewGameScreen.opacity = 0;
                        Logic.shuffleDeck();
                    }
                }
                FancyButton {
                    text: qsTr('Cancel')
                    onClicked: confirmNewGameScreen.opacity = 0;
                }
            }
        }
    }

    // Victory screen
    Rectangle {
        id: victoryScreen
        anchors.fill: parent
        color: '#88aadda9'
        visible: opacity > 0
        opacity: 0

        MouseArea {
            anchors.fill: parent
            enabled: parent.visible
        }

        Behavior on opacity {
            PropertyAnimation { duration: 500 }
        }

        /** Fireworks **/
        ParticleSystem {
            id: sys
        }
        ImageParticle {
            system: sys
            source: "glowdot.png"
            color: "white"
            colorVariation: 1.0
            alpha: 0.1
        }
        Component {
            id: emitterComp
            Emitter {
                id: container
                Emitter {
                    id: emitMore
                    system: sys
                    emitRate: 128
                    lifeSpan: 600
                    size: 16
                    endSize: 8
                    velocity: AngleDirection {angleVariation:360; magnitude: 60}
                }

                property int life: 2600
                property real targetX: 0
                property real targetY: 0
                function go() {
                    xAnim.start();
                    yAnim.start();
                    container.enabled = true
                }
                system: sys
                emitRate: 32
                lifeSpan: 600
                size: 24
                endSize: 8
                NumberAnimation on x {
                    id: xAnim;
                    to: targetX
                    duration: life
                    running: false
                }
                NumberAnimation on y {
                    id: yAnim;
                    to: targetY
                    duration: life
                    running: false
                }
                Timer {
                    interval: life
                    running: true
                    onTriggered: container.destroy();
                }
            }
        }
        Timer {
            interval: 800
            triggeredOnStart: true
            running: victoryScreen.visible && ""+settings.value("effects", "true") == "true"
            repeat: true
            onTriggered: customEmit(Math.random() * 320, Math.random() * 480)
            function customEmit(x,y) {
                //! [0]
                for (var i=0; i<8; i++) {
                    var obj = emitterComp.createObject(victoryScreen);
                    obj.x = x
                    obj.y = y
                    obj.targetX = Math.random() * victoryScreen.width + obj.x
                    obj.targetY = Math.random() * victoryScreen.height + obj.y
                    obj.life = Math.round(Math.random() * 2400) + 200
                    obj.emitRate = Math.round(Math.random() * 32) + 32
                    obj.go();
                }
                //! [0]
            }
        }
        /** Fireworks **/

        Image {
            id: victoryImage
            anchors.centerIn: parent
            width: parent.width * 0.5
            height: width * 0.778967867575463
            source: 'victory.png'
            fillMode: Image.PreserveAspectFit
        }

        Text {
            text: qsTr('Victory!')
            anchors {
                verticalCenterOffset: victoryImage.height * 0.21
                centerIn: parent
            }
            font.pixelSize: victoryImage.height * 0.13
            font.bold: true
            font.family: lobster.name
            style: Text.Outline
            styleColor: "black"
            color: 'white'
        }

        FancyButton {
            id: shuffleButton2
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                margins: 50
            }
            text: qsTr('New Game');
            onClicked: {
                victoryScreen.opacity = 0;
                Logic.shuffleDeck();
            }
        }
    }
}
