var cardComponent;
var cards = [];
var lanes = [];

var cardmaps = [];
var restoring = false; // Internally used to stop saving state while restoring a state (since we use the same addToLane() methods.)

var solveQueue = []; // This is a card list of cards to move to solve, to make it look crazy cool when it happens instead of *jerp* all done.
var solveQueueTimer = false;

var resizedTimer = false;

var metrics = {
    'startTime': 0, // This is from when we Start or Resume a game, and it's that point in time.
    'gameTime': 0, // This is Saved and Restored to track SECONDS elapsed, to be added to above, and resaved if we save and quit
    'moves': 0,
    'bestTime': 0, // In SECONDS
    'gamesPlayed': 0, // Increments with "New Game"
    'gamesWon': 0 // Stacked all Kings this many times
}

function init()
{
    var oldmaps = settings.value('cardmaps');
    if( oldmaps )
        cardmaps = oldmaps;

    buildCardComponent();
}

function Timer() {
    return Qt.createQmlObject("import QtQuick 2.0; Timer {}", topContainer);
}

function deckBuilt()
{
    // This requires a small delay, because QML Engine takes a minute to give metrics to things:
    var timer = new Timer();
    timer.interval = 150;
    timer.repeat = false;
    timer.triggered.connect(function () {
        registerLanes();
        if( cardmaps.length > 0 )
        {
            // Restore last state
            restoreState(false);

            checkSolve();
        }
        else
            shuffleDeck();
    });
    timer.start();
}

function areaResized()
{
    if( resizedTimer )
        resizedTimer.stop();

    var timer = new Timer();
    timer.interval = 50;
    timer.repeat = false;
    timer.triggered.connect(function () {
        if( cards.length == 0 )
            return;

        if( restoring )
        {
            // If resizing, restart this timer:
            return areaResized();
        }

        reLayCards();
        delete resizedTimer;
        resizedTimer = false;
    });
    timer.start();
    resizedTimer = timer;
}

function registerLanes() {
    registerLane(bankLane);
    registerLane(wasteLane);
    registerLane(aceLane1);
    registerLane(aceLane2);
    registerLane(aceLane3);
    registerLane(aceLane4);
    registerLane(lane1);
    registerLane(lane2);
    registerLane(lane3);
    registerLane(lane4);
    registerLane(lane5);
    registerLane(lane6);
    registerLane(lane7);
}

function registerLane(laneObj)
{
    //console.log("Registering lane '"+laneObj.laneId+"'");
    lanes.push( {'obj':laneObj, 'cards':[]} );
}

function buildCards() {
    var sc = [ 'C', 'S', 'D', 'H' ];
    var vc = [ 'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K' ];

    //console.log("Building deck..");
    var layer = 10;
    for( var vcn=0; vcn < vc.length; vcn++ )
    {
        for( var scn = 0; scn < sc.length; scn++ )
        {
            var card = cardComponent.createObject(topContainer);
            card.x = 0; //bankLane.x;
            card.y = 0; //bankLane.y;
            card.value = vcn;
            card.valueLabel = vc[vcn];
            card.suitCode = sc[scn];
            //card.faceDown = true;
            card.z = layer;
            card.clicked.connect( cardClicked );
            card.dropped.connect( cardDropped );
            card.dragging.connect( cardDragging );
            //addToLane('bank', card);
            cards.push( card );
            layer++;
        }
    }
}

function startSolveQueue()
{
    restoring = true;

    var timer = new Timer();
    timer.interval = 100;
    timer.repeat = true;
    timer.triggered.connect(function () {
        var didSomething = solve();
        if( !didSomething )
        {
            solveQueueTimer.stop();
            delete solveQueueTimer;
            solveQueueTimer = false;
            restoring = false;
            return;
        }
    });
    timer.start();
    solveQueueTimer = timer;
}

function saveState() {
    if( restoring )
        return;

    //console.log("Saving state...");
    var nlanes = [];
    for( var x=0; x < lanes.length; x++ )
    {
        var lent = lanes[x];
        var stack = lent['cards'];
        var obj = lent['obj'];
        var ncards = [];
        for( var y=0; y < stack.length; y++ )
        {
            var cent = stack[y];
            ncards.push( {'v':cent.value, 's':cent.suitCode, 'f':cent.faceDown, 'p':y} );
        }
        nlanes.push( {'l':obj.laneId, 'c':ncards} );
    }
    cardmaps.push( nlanes );
    if( cardmaps.length > 30 )
        cardmaps.splice(0,1); // Stay skinny.

    settings.setValue('cardmaps', cardmaps);
}

function restoreState(discardLast) {
    //console.log("Restoring last state...");
    var nlanes = cardmaps.pop();
    if( discardLast )
        nlanes = cardmaps.pop(); // We actually need the state before this one.

    if( !nlanes )
        return;

    clearLanes();
    restoring = true;

    var cardsMoved = 0;
    var cardsFlipped = 0;
    for( var x=0; x < nlanes.length; x++ )
    {
        var sent = nlanes[x];
        var laneId = sent['l'];
        var stack = sent['c'];
        var lent = findLane(laneId);

        for( var y=0; y < stack.length; y++ )
        {
            var cent = stack[y];
            var card = findCard( cent['s'], cent['v'] );
            //card.faceDown = cent['f'];

            if( cent['f'] != card.faceDown )
                cardsFlipped++;

            if( cent['f'] )
                card.flipDown(false); // false == Animate
            else
                card.flipUp(false); // false == Animate

            if( card.laneId != laneId )
                cardsMoved++;

            addToLane(laneId, card);
        }
    }
    if( cardsMoved > 3 )
        topContainer.playClip("shuffle");
    else {
        topContainer.playClip("slide");

        if( cardsFlipped > 0 )
            topContainer.playClip("flip");
    }

    cardmaps.push(nlanes);
    restoring = false;
}

function shuffleDeck() {
    topContainer.redeals = 3;
    topContainer.canSolve = false;
    cardmaps = []; // Reset undo history.
    restoring = true; // We don't want to "undo" this either:

    //shuffleSound.play();

    clearLanes();
    var ndeck = shuffle(cards);
    var layer = 10;
    for( var p=0; p < ndeck.length; p++ )
    {
        var card = ndeck[p];
        //card.x = bankLane.x;
        //card.y = bankLane.y;
        card.z = layer++;
        //card.faceDown = true;
        card.flipDown(true); // false == Animate / true == Immediate
        ndeck[p] = card;
        addToLane('bank', card);
    }
    cards = ndeck;

    fillTableaus();
    restoring = false;
    saveState();
}

function fillTableaus() {
    var cpos = 0;
    topContainer.playClip("shuffle");

    for( var x=0; x < 7; x++ )
    {
        var lname = 'lane'+(x+1);

        // Facedowns:
        for( var y=0; y < x; y++ )
        {
            //cards[cpos].faceDown = true;
            cards[cpos].flipDown(false); // false == Animate
            addToLane( lname, cards[cpos++] );
        }

        //cards[cpos].faceDown = false;
        cards[cpos].flipUp(false); // false == Animate
        addToLane( lname, cards[cpos++] );
    }
}

function clearLanes() {
    var nlanes = [];
    for( var x=0; x < lanes.length; x++ )
    {
        var lent = lanes[x];
        nlanes.push( {'cards':[], 'obj':lent['obj']} );
    }
    lanes = nlanes;
}

function reLayCards() {
    for( var li=0; li < lanes.length; li++ )
    {
        var lane = lanes[li];
        var ents = lane['cards'];
        var obj = lane['obj'];
        var mtpos = obj.mapToItem(topContainer, 0, 0);

        if( obj.laneType == 'stack' )
        {
            for( var x=0; x < ents.length; x++ )
            {
                ents[x].z = ents[x].origZ = 10+x;
                //ents[x].moveTo( mtpos.x, mtpos.y, ents[x].z, false);
                ents[x].warpTo( mtpos.x, mtpos.y );
            }
        }
        else if( obj.laneType == 'tableau' )
        {
            for( var x=0; x < ents.length; x++ )
            {
                ents[x].z = ents[x].origZ = 10+x;
                //ents[x].moveTo( mtpos.x, mtpos.y + (x*30), ents[x].z, false );
                ents[x].warpTo( mtpos.x, mtpos.y + (x*topContainer.cardSpacing) );
            }
        }
        updateLane(obj.laneId, lane);
    }
}

function addToLane(laneId, card, immediate)
{
    // Save children state to move them too:
    var children = []
    //console.log("ADDING "+card.valueLabel+" "+card.suitSymbol+" with LaneID "+card.laneId+" to "+laneId);

    var oldLane = card.laneId;
    var lane = findLane(oldLane);
    if( lane && lane.obj && lane.obj.laneType == 'tableau' )
        children = gatherKids(card);

    card.laneId = laneId;
    lane = findLane(laneId);
    if( !lane )
        return console.log("Failed to addToLane, lane not found: "+laneId);

    removeFromLanes(card);

    var obj = lane['obj'];
    var ents = lane['cards'];

    var mtpos = obj.mapToItem(topContainer, 0, 0);

    //console.log("Moving to "+mtpos.x+"x"+mtpos.y);
    ents.push( card );

    if( obj.laneType == 'stack' )
    {
        for( var x=0; x < ents.length; x++ )
            ents[x].z = ents[x].origZ = 10+x;

        //console.log("Card "+card.valueLabel+" "+card.suitSymbol+" moving from "+oldLane+" from "+laneId+".");
        if( immediate )
            card.warpTo( mtpos.x, mtpos.y );
        else
            card.moveTo( mtpos.x, mtpos.y, 170+ents.length, false);
    }
    else if( obj.laneType == 'tableau' )
    {
        for( var x=0; x < ents.length; x++ )
        {
            ents[x].z = ents[x].origZ = 10+x;
            //ents[x].moveTo( mtpos.x, mtpos.y + (x*30), 70+x, false );
        }
        card.z = 10+ents.length;
        if( immediate )
            card.warpTo( mtpos.x, mtpos.y + ((ents.length-1)*topContainer.cardSpacing) );
        else
            card.moveTo( mtpos.x, mtpos.y + ((ents.length-1)*topContainer.cardSpacing), 170+ents.length, false );
    }
    else {
        console.log("Card "+card.valueLabel+" "+card.suitSymbol+" moving to "+laneId+" but it isn't a stack or tableau.");
    }

    lane['cards'] = ents;
    updateLane(laneId, lane);

    if( children.length > 0 )
        addToLane( laneId, children[0], immediate );
}

function findLane(laneId)
{
    for( var x=0; x < lanes.length; x++ )
    {
        var lent = lanes[x];
        var obj = lent['obj'];
        if( obj.laneId == laneId )
            return lent;
    }
    return false;
}

function findCard(suit, value)
{
    for( var x=0; x < cards.length; x++ )
    {
        var card = cards[x];
        if( card.value == value && card.suitCode == suit )
            return card;
    }
    return false;
}

function removeFromLanes(card)
{
    for( var x=0; x < lanes.length; x++ )
    {
        var ncards = [];
        var lent = lanes[x];
        var cards = lent['cards'];
        for( var y=0; y < cards.length; y++ )
            if( cards[y] != card )
                ncards.push( cards[y] );
        lent['cards'] = ncards;
        lanes[x] = lent;
    }
}

function updateLane(laneId, lane)
{
    for( var x=0; x < lanes.length; x++ )
    {
        var lent = lanes[x];
        var obj = lent['obj'];
        if( obj.laneId == laneId )
        {
            lanes[x] = lane;
            //console.log('Updating lane "'+lane.obj.laneId+'" which now has '+lane.cards.length+' items.');
            return;
        }
    }
    return false;
}
/*
function moveCard(card, dest)
{
    var lane = findLane(dest);
    if( !lane )
        return console.log('Failed to find lane: '+dest);
    var obj = lane['obj'];
    var mtpos = obj.mapToItem(topContainer, 0, 0);

    addToLane(dest, card);
}
*/
function finishBankReset(animCard) {
    // The purpose of this function is to "unhide" the rest of the deck UNDER the animated card!
    animCard.moveComplete.disconnect( finishBankReset );
    var lane = findLane('bank');
    var cards = lane['cards'];

    console.log("Finished flipping, unhide the rest of the bank...");
    for( var x=0; x < cards.length; x++ )
        cards[x].visible = true;
}

function resetBank() {
    var lane = findLane('waste');
    var cards = lane['cards'];

    if( !cards || cards.length == 0 )
        return;

    if( !restoring && ""+settings.value("unlimited", "true") == "false" )
    {
        // HANDLE IT.
        if( topContainer.redeals <= 0 )
            return; // Newp~

        topContainer.redeals--;
    }

    topContainer.playClip("shuffle");

    // Only move top card:
    var animCard = cards[ cards.length - 1 ];
    animCard.flipDown(false);
    //animCard.moveComplete.connect( finishBankReset );
    addToLane('bank', animCard, false);

    // Move these without animations, just animate the top card, then unhide these:
    for( var x=cards.length-2; x >= 0; x-- )
    {
        cards[x].visible = false;
        //cards[x].flipDown(true);
        //addToLane('bank', cards[x], true);
        cards[x].flipDown(false);
        addToLane('bank', cards[x], false);
    }

    if( !restoring )
        saveState();
}

function flipBank()
{
    var lane = findLane('bank');
    var cards = lane['cards'];
    var card = cards[ cards.length-1 ];
    //var card = cards[ 0 ];
    topContainer.playClip("flip");

    card.flipUp(false); // false == Animate
    addToLane('waste', card);

    if( !restoring )
        saveState();
}

function bankClicked()
{
    // We're in the bank, flip to Waste.
    var lane = findLane('bank');
    var cards = lane['cards'];
    if( cards.length == 0 )
        return resetBank();

    flipBank();
}

function wasteClicked()
{
    var lane = findLane('waste');
    if( lane['cards'].length == 0 )
        return flipBank();

    console.log("I don't know what to do now.");
}

function cardDropped(card, x, y)
{
    //console.log("Card dropped at "+x+"x"+y);
    if( card.faceDown )
        return card.resetPosition();

    // Check all lanes, first Aces:
    for( var j=0; j < 4; j++ )
    {
        var lid = 'ace'+(j+1);
        var lane = findLane(lid);
        var obj = lane['obj'];
        var apos = obj.mapToItem(topContainer, 0, 0);
        //console.log("Lane "+obj.laneId+" is at "+apos.x+"x"+apos.y+"+"+obj.width+"x"+obj.height);
        if( x >= apos.x && x <= apos.x + obj.width && y >= apos.y && y <= apos.y+obj.height )
        {
            //console.log("DROP TO ACE LANE "+obj.laneId);
            var lastId = card.laneId;
            var ret = placeOnAces(card, obj.laneId);

            if( ret )
            {
                // If we succeeded on moving this card, flip over the second to last if we have one.
                // But we need a new lane instance, since it will have changed:
                lane = findLane(lastId);
                var cards = lane['cards'];
                if( cards.length == 0 )
                    return saveState();

                cards[ cards.length-1 ].flipUp(false);
                checkSolve();
                //cards[ cards.length-1 ].faceDown = false;
                return saveState();
            }
        }
    }

    // Check card ENDS:
    for( var j=0; j < 7; j++ )
    {
        var lid = 'lane'+(j+1);
        var lane = findLane(lid);
        var cards = lane['cards'];
        if( !cards || cards.length < 1 )
            continue;

        var obj = cards[ cards.length-1 ];
        var apos = obj.mapToItem(topContainer, 0, 0);
        //console.log("Lane "+obj.laneId+" is at "+apos.x+"x"+apos.y+"+"+obj.width+"x"+obj.height);
        if( x >= apos.x && x <= apos.x + obj.width && y >= apos.y && y <= apos.y+obj.height )
        {
            var lastId = card.laneId;
            var ret = placeOnTableau(card, obj.laneId);

            if( ret )
            {
                // If we succeeded on moving this card, flip over the second to last if we have one.
                // But we need a new lane instance, since it will have changed:
                lane = findLane(lastId);
                var cards = lane['cards'];
                if( cards.length == 0 )
                    return saveState();

                topContainer.playClip("flip");
                cards[ cards.length-1 ].flipUp(false);
                checkSolve();
                //cards[ cards.length-1 ].faceDown = false;
                return saveState();
            }
        }
    }

    // Check empty card lanes:
    for( var j=0; j < 7; j++ )
    {
        var lid = 'lane'+(j+1);
        var lane = findLane(lid);
        var cards = lane['cards'];
        if( cards.length > 1 )
            continue;

        var obj = lane['obj'];
        var apos = obj.mapToItem(topContainer, 0, 0);
        //console.log("Lane "+obj.laneId+" is at "+apos.x+"x"+apos.y+"+"+obj.width+"x"+obj.height);
        if( x >= apos.x && x <= apos.x + obj.width && y >= apos.y && y <= apos.y+obj.height )
        {
            var lastId = card.laneId;
            var ret = placeOnTableau(card, obj.laneId);

            if( ret )
            {
                // If we succeeded on moving this card, flip over the second to last if we have one.
                // But we need a new lane instance, since it will have changed:
                lane = findLane(lastId);
                var cards = lane['cards'];
                if( cards.length == 0 )
                    return saveState();

                topContainer.playClip("flip");
                cards[ cards.length-1 ].flipUp(false);
                checkSolve();
                //cards[ cards.length-1 ].faceDown = false;
                return saveState();
            }
        }
    }

    card.resetPosition();
}

function cardClicked(card, automated)
{
    //console.log( "Card "+card.valueLabel+" "+card.suitSymbol+" in lane "+card.laneId+" clicked.");
    if( card.laneId == 'bank' )
        return bankClicked();
    else if( card.laneId == 'ace1' || card.laneId == 'ace2' || card.laneId == 'ace3' || card.laneId == 'ace4' )
    {
        if( placeOnTableau(card) )
            return saveState();
    }
    else if( card.laneId == 'waste' )
    {
        // If it's an Ace, it can only go in a free ace slot:
        if( !placeOnAces(card) )
        {
            if( placeOnTableau(card) )
                return saveState();
        } else return saveState();
    } else {
        var lane = findLane(card.laneId);
        if( !lane )
            return console.log("Failed to find a lane for card!");

        var kids = gatherKids(card);
        if( lane.obj.laneType == 'tableau' ) {
            //console.log("Got tableau card: "+card.valueLabel+' '+card.suitSymbol);
            if( !card.faceDown ) // Well, no.
            {
                // Only if we aren't a lane parent with children:
                if( lane.cards[ lane.cards.length-1 ] == card )
                {
                    // Try to place on aces first, only if we don't have children:
                    var lastId = card.laneId;
                    if( kids.length == 0 && placeOnAces(card) )
                    {
                        // If we succeeded on moving this card, flip over the second to last if we have one.
                        // But we need a new lane instance, since it will have changed:
                        lane = findLane(lastId);
                        var cards = lane['cards'];
                        if( cards.length == 0 )
                            return saveState();

                        topContainer.playClip("flip");
                        cards[ cards.length-1 ].flipUp(false);
                        checkSolve();
                        //cards[ cards.length-1 ].faceDown = false;
                        return saveState();
                    }
                }

                // Otherwise try to place elsewhere on tableau:
                {
                    var lastId = card.laneId;
                    var ret = placeOnTableau(card);

                    if( ret )
                    {
                        // If we succeeded on moving this card, flip over the second to last if we have one.
                        // But we need a new lane instance, since it will have changed:
                        lane = findLane(lastId);
                        var cards = lane['cards'];
                        if( cards.length == 0 )
                            return saveState();

                        topContainer.playClip("flip");
                        cards[ cards.length-1 ].flipUp(false);
                        checkSolve();
                        //cards[ cards.length-1 ].faceDown = false;
                        return saveState();
                    }
                }
            } // card.faceDown
        } // tableau
    }

    card.wiggle(); // Indicate nowhere to put it.
}

function gatherKids(card)
{
    var l = findLane( card.laneId );
    var cards = l['cards'];
    var kids = [];
    var onKids = false;
    for( var j=0; j < cards.length; j++ )
    {
        var c = cards[j];
        if( !onKids && c == card )
        {
            onKids = true;
            continue;
        }
        else if( onKids )
            kids.push(c);
    }
    return kids;
}

function cardDragging(which)
{
    which.origZ = which.z;
    which.origX = which.x;
    which.origY = which.y;
    which.z = 174;

    var kids = gatherKids( which );
    if( !kids || kids.length == 0 )
    {
        which.childCards = [];
        return;
    }

    which.childCards = kids;
    for( var cn=0; cn < kids.length; cn++ )
    {
        var cc = kids[cn];
        cc.origZ = cc.z;
        cc.origX = cc.x;
        cc.origY = cc.y;
        cc.z = 175+cn;
    }
}

function solve() {
    // ... phew, let's go:
        // FOR EACH ACE LANE...
        for( var j=0; j < 4; j++ )
        {
            var destId = 'ace'+(j+1)
            var aent = findLane(destId);
            var aMaxVal = -1; // Start at -1 because we may be empty.
            var asuit = false;
            if( aent['cards'] && aent['cards'].length )
            {
                var acards = aent['cards'];
                for( var ac=0; ac < acards.length; ac++ )
                {
                    if( acards[ac].value > aMaxVal )
                    {
                        asuit = acards[ac].suitCode;
                        aMaxVal = acards[ac].value;
                    }
                }
            }

            // CHECK LANES:
            for( var x=0; x < 7; x++ )
            {
                var laneId = 'lane'+(x+1);
                var lent = findLane(laneId);
                var cards = lent['cards'];
                if( !cards || cards.length == 0 )
                    continue;

                var cent = cards[ cards.length-1 ];
                if( cent.value == 0 && asuit == false ) // We have an Ace and a Hole
                {
                    //console.log("LANE A: Clicking: "+cent.valueLabel+" "+cent.suitSymbol+" cuz "+aMaxVal+" "+asuit);
                    cardClicked(cent, true);
                    return true;
                }
                else if( cent.suitCode == asuit && cent.value == aMaxVal+1 )
                {
                    //console.log("LANE B: Clicking: "+cent.valueLabel+" "+cent.suitSymbol+" cuz "+aMaxVal+" "+asuit);
                    cardClicked(cent, true);
                    return true;
                }
            }
        }

        // FOR EACH ACE LANE...
        for( var j=0; j < 4; j++ )
        {
            var destId = 'ace'+(j+1)
            var aent = findLane(destId);
            var aMaxVal = -1; // Start at -1 because we may be empty.
            var asuit = false;
            if( aent['cards'] && aent['cards'].length )
            {
                var acards = aent['cards'];
                for( var ac=0; ac < acards.length; ac++ )
                {
                    if( acards[ac].value > aMaxVal )
                    {
                        asuit = acards[ac].suitCode;
                        aMaxVal = acards[ac].value;
                    }
                }
            }

            // CHECK WASTE AND BANK:
            var went = findLane('waste');
            var bent = findLane('bank');
            var ccount = 0;
            if( went['cards'] && went['cards'].length > 0 )
                ccount += went['cards'].length;
            if( bent['cards'] && bent['cards'].length > 0 )
                ccount += bent['cards'].length;
            for( var x=0; x < ccount+1; x++ )
            {
                var went = findLane('waste');
                var cards = went['cards'];
                if( !cards || cards.length == 0 )
                {
                    bankClicked();
                    continue;
                }

                var cent = cards[ cards.length-1 ];
                if( cent.value == 0 && asuit == false ) // We have an Ace and a Hole
                {
                    //console.log("STACK A: Clicking: "+cent.valueLabel+" "+cent.suitSymbol+" cuz "+aMaxVal+" "+asuit);
                    cardClicked(cent, true);
                    return true;
                }
                else if( cent.suitCode == asuit && cent.value == aMaxVal+1 )
                {
                    //console.log("STACK B: Clicking: "+cent.valueLabel+" "+cent.suitSymbol+" cuz "+aMaxVal+" "+asuit);
                    cardClicked(cent, true);
                    return true;
                }
                bankClicked();
            }
        }

    console.log("Done trying to solve, didn't get anything.");

    //restoring = false;
    return false;
}

function checkSolve() {
    if( restoring ) return false;

    for( var x=0; x < 7; x++ )
    {
        var laneId = 'lane'+(x+1);
        var lent = findLane(laneId);
        var cards = lent['cards'];
        if( !cards || cards.length == 0 )
            continue;

        if( cards[0].faceDown )
            return false;
/*
        for( var y=0; y < cards.length; y++ )
        {
            if( lent['cards'][y].faceDown )
            {
                var cent = lent['cards'][y];
                //console.log("CANNOT SOLVE BECAUSE: "+cent.valueLabel+" "+cent.suitSymbol+" is FaceDown on lane "+laneId);
                return false;
            }
        }
*/
    }

    topContainer.canSolve = true;
    console.log("CAN SOLVE!");
    return true;
}

function placeOnTableau(card, target)
{
    var csc = ( card.suitCode == 'D' || card.suitCode == 'H' ) ? 'R' : 'B';
    //console.log("Tableau placing "+card.valueLabel+' '+card.suitCode+' with target '+target);

    // Find a free slot:
    var laneNames = [ 'lane1', 'lane2', 'lane3', 'lane4', 'lane5', 'lane6', 'lane7' ];
    for( var x=0; x < laneNames.length; x++ )
    {
        var an = laneNames[x];
        if( target && an != target )
            continue;

        var lent = findLane(an);
        if( !lent )
        {
            console.log('Failed to find lane '+an);
            return false;
        }

        var obj = lent['obj'];
        var cards = lent['cards'];
        if( cards.length == 0 && card.valueLabel == 'K' )
        {
            // Go here, and return:
            addToLane( an, card );
            topContainer.playClip("slide");
            return true;
        } else if( cards.length > 0 ) {
            // See if we can put this on the last slot:
            var lc = cards[ cards.length - 1 ];
            var lcsc = ( lc.suitCode == 'D' || lc.suitCode == 'H' ) ? 'R' : 'B';

            if( csc != lcsc && card.value+1 == lc.value )
            {
                // It fits, move it there.
                addToLane( an, card );
                topContainer.playClip("slide");
                return true;
            }
        }
    }
    return false;
}

function placeOnAces(card, target)
{
    // Find a free slot:
    var aceNames = [ 'ace1', 'ace2', 'ace3', 'ace4' ];
    for( var x=0; x < aceNames.length; x++ )
    {
        var an = aceNames[x];
        if( target && an != target )
            continue;

        var lent = findLane(an);
        if( !lent )
        {
            console.log('Failed to find lane '+an);
            return false;
        }

        var obj = lent['obj'];
        var cards = lent['cards'];
        if( cards.length == 0 )
        {
            if( card.value == 0 )
            {
                // Go here, and return:
                addToLane( an, card );
                topContainer.playClip("slide");
                return true;
            }
        } else {
            // See if we can put this on the last slot:
            var lc = cards[ cards.length - 1 ];
            if( card.suitCode == lc.suitCode && card.value == lc.value + 1 )
            {
                // It fits, move it there.
                addToLane( an, card );
                topContainer.playClip("slide");
                checkVictory();
                return true;
            }
        }
    }
    return false;
}

function checkVictory()
{
    var aceNames = [ 'ace1', 'ace2', 'ace3', 'ace4' ];
    for( var x=0; x < aceNames.length; x++ )
    {
        var an = aceNames[x];
        var lent = findLane(an);
        if( !lent )
        {
            console.log('Failed to find lane '+an);
            return false;
        }

        var obj = lent['obj'];
        var cards = lent['cards'];
        if( cards.length == 0 )
            return false;

        var topCard = cards[ cards.length - 1 ];
        if( topCard.value != 12 )
            return false;
    }

    console.log("We win!");
    topContainer.playClip("victory");
    victoryScreen.opacity = 1;
    return true;
}

function dumpState() {
    for( var x=0; x < lanes.length; x++ )
    {
        var lent = lanes[x];
        var stack = lent['cards'];
        var obj = lent['obj'];
        console.log("Cards in lane "+obj.laneId);
        console.log('--------------');
        for( var y=0; y < stack.length; y++ )
        {
            var cent = stack[y];
            console.log(' -> '+cent.valueLabel+' '+cent.suitSymbol);
        }
        console.log("\n\n");
    }
}

function buildCardComponent()
{
    cardComponent = Qt.createComponent("Card.qml");
    if( cardComponent.status == Component.Ready )
    {
        buildCards();
        deckBuilt();
    }
    else if( cardComponent.status == Component.Error )
        console.log("Error loading component:", cardComponent.errorString());
    else
    cardComponent.statusChanged.connect( function() {
        if( cardComponent.status == Component.Error )
            console.log("Error loading component:", cardComponent.errorString());
        else
        if( cardComponent.status != Component.Ready )
            return;
        buildCards();
        deckBuilt();
    } );
}

// Fisher-Yates (aka Knuth) Shuffle
// https://github.com/coolaj86/knuth-shuffle
function shuffle(array) {
  var currentIndex = array.length, temporaryValue, randomIndex;

  // While there remain elements to shuffle...
  while (0 !== currentIndex) {

    // Pick a remaining element...
    randomIndex = Math.floor(Math.random() * currentIndex);
    currentIndex -= 1;

    // And swap it with the current element.
    temporaryValue = array[currentIndex];
    array[currentIndex] = array[randomIndex];
    array[randomIndex] = temporaryValue;
  }

  return array;
}

/* BACKGROUND IMAGE: https://jcutrer.com/photos/abstract-photos-textures (Royalty Free)
 * Suit symbols: https://www.pngguru.com/free-transparent-background-png-clipart-bisrr
 * Victory thing: https://www.klipartz.com/en/sticker-png-tvuhy
 * CARD IMAGES: Adrian Kennard (https://commons.wikimedia.org/wiki/User:TheRealRevK)
 * Lobster Font: Copyright (c) 2010, Pablo Impallari (www.impallari.com|impallari@gmail.com)
 * Ostrich Sans: (c) Tyler Finck @ http://www.finck.co
 * Card icon: http://clipart-library.com/clipart/n982255.htm
 * Menu label: Aidwata (GNOME)
 */
