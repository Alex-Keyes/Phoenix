import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0

import vg.phoenix.cache 1.0
import vg.phoenix.themes 1.0

Rectangle {
    id: boxartGridBackground;
    width: 100;
    height: 62;

    DropdownMenu {
        id: dropDownMenu;
    }

    PhxScrollView {
        id: scrollView;
        anchors {
            fill: parent;
            topMargin: 35;
        }

        Rectangle {
            opacity: gridView.atYBeginning ? 0.0 : 0.3;
            z: 100;
            anchors {
                top: parent.top;
                left: parent.left;
                right: parent.right;
            }

            height: 25;
            gradient: Gradient {
                GradientStop { position: 0.0; color: "black"; }
                GradientStop { position: 1.0; color: "transparent"; }
            }

            Behavior on opacity {
                PropertyAnimation {
                    duration: 200;
                }
            }
        }

        Rectangle {
            opacity: gridView.atYEnd ? 0.0 : 0.3;
            z: 100;
            anchors {
                bottom: parent.bottom;
                left: parent.left;
                right: parent.right;
            }

            height: 25;
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent"; }
                GradientStop { position: 1.0; color: "black"; }
            }

            Behavior on opacity {
                PropertyAnimation {
                    duration: 200;
                }
            }
        }

        contentItem: GridView {
            id: gridView;

            model: libraryModel;

            // The max height and width of the grid's cells. This can be tweaked
            // to change the default size of the boxart.
            property int maxCellHeight: 225;
            property bool clampEdges: parent.width >= maxCellHeight;

            displaced: Transition {
                    NumberAnimation { properties: "x,y,visible,width,height,opacity"; duration: 1000 }
            }

            // Yes this isn't ideal, but it is a work around for the view resetting back to 0
            // whenever a game is imported.
            property real lastY: 0;

            onContentYChanged: {
                if (contentY == 0) {
                    if ( Math.round( lastY ) !== 0.0 ) {
                        contentY = lastY;
                    }
                }
                else
                    lastY = contentY;
            }

            anchors {
                top: parent.top;
                left: parent.left;
                right: parent.right;
                bottom: parent.bottom;

                leftMargin: gridView.clampEdges ? ( ( parent.width % cellWidth ) / 2 ) : 0;
                rightMargin: leftMargin;
            }

            // If the grid's width is less than the maxCellWidth, get
            // the grid to scale the size of the grid items, so that the transition looks really
            // seamless.
            cellHeight: clampEdges ? maxCellHeight : parent.width;
            cellWidth: cellHeight;

            boundsBehavior: Flickable.StopAtBounds;
            Component.onCompleted: libraryModel.updateCount();

            delegate: Rectangle {
                id: gridItem;
                height: gridView.cellHeight//gridView.clampEdges ? gridView.cellHeight : gridView.width * 0.75;
                width: gridView.cellWidth;

                color: "transparent";//"lightgray"

                ColumnLayout {
                    spacing: 8;
                    anchors {
                        top: parent.top;
                        bottom: parent.bottom;
                        bottomMargin: 24;
                        left: parent.left;
                        right: parent.right;
                        leftMargin: 24
                        rightMargin: 24;
                    }

                    Rectangle {
                        id: gridItemImageContainer;
                        color: gridItemImage.source === "" ? "white" : "transparent";
                        Layout.fillHeight: true;
                        Layout.fillWidth: true;

                        RectangularGlow {
                            anchors.bottom: gridItemImage.bottom;
                            height: gridItemImage.paintedHeight;
                            width: gridItemImage.paintedWidth;
                            glowRadius: 9;
                            spread: 0.2;
                            color: "black";
                            cornerRadius: glowRadius;
                            opacity: 0.35;
                        }

                        Image {
                            id: gridItemImage;
                            visible: true;
                            anchors {
                                left: parent.left;
                                right: parent.right;
                                bottom: parent.bottom;
                            }



                            Rectangle {
                                id: imageTopAccent;
                                y: gridItemImage.y + ( gridItemImage.height - gridItemImage.paintedHeight );
                                anchors {
                                    left: parent.left;
                                    right: parent.right;
                                }

                                height: 1;
                                opacity: 0.3;
                                color: "white";
                            }

                            Rectangle {
                                id: imageTopLeft;
                                anchors {
                                    top: imageTopAccent.bottom;
                                    left: parent.left;
                                    bottom: parent.bottom;
                                }

                                width: 1;
                                opacity: 0.10;
                                color: "white";
                            }

                            Rectangle {
                                id: imageTopRight;
                                anchors {
                                    top: imageTopAccent.bottom;
                                    right: parent.right;
                                    bottom: parent.bottom;
                                }

                                width: 1;
                                opacity: 0.10;
                                color: "white";
                            }

                            fillMode: Image.PreserveAspectFit;
                            onStatusChanged: {
                                if ( status == Image.Null || status === Image.Error) {
                                    console.log("Error in " + source)
                                }
                            }

                            height: parent.height;
                            asynchronous: true;
                            source: imageCacher.cachedUrl;
                            verticalAlignment: Image.AlignBottom;

                            sourceSize {
                                height: 400;
                                width: 400;
                            }

                            MouseArea {
                                anchors.fill: parent;
                                onClicked: {
                                    gridView.currentIndex = index;
                                }
                            }

                            ImageCacher {
                                id: imageCacher;

                                imageUrl: artworkUrl;
                                identifier: sha1;


                                Component.onCompleted: {
                                    cache();
                                }
                            }
                        }
                    }

                    Text {
                        id: titleText;
                        text: title;
                        color: index === gridView.currentIndex ? PhxTheme.common.highlighterFontColor : PhxTheme.common.baseFontColor;
                        Layout.fillWidth: true;
                        elide: Text.ElideRight;
                        font {
                            pixelSize: gridItem.height * 0.05;
                        }
                    }
                    /*

                    Text {
                        id: platformText;
                        anchors {
                            top: titleText.bottom;
                            topMargin: 0;
                        }

                        text: system;
                        color: PhxTheme.common.baseFontColor;
                        Layout.fillWidth: true;
                        elide: Text.ElideRight;
                    }
                    Text {
                        id: absPath;
                        anchors {
                            top: platformText.bottom;

                        }
                        text: sha1//absolutePath;
                        color: PhxTheme.common.baseFontColor;
                        Layout.fillWidth: true;
                        elide: Text.ElideMiddle;
                    }*/
                }
            }
        }
    }
}

