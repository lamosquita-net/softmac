// SPDX-License-Identifier: MPL-2.0
// FlyHand: librevenge drawing interface that fills a flyhand::Model.
#pragma once

#include <librevenge/librevenge.h>

#include "FHModel.h"

namespace flyhand {

class Painter : public librevenge::RVNGDrawingInterface {
public:
  explicit Painter(Model &model) : m_model(model) {}

  void startDocument(const librevenge::RVNGPropertyList &) override {}
  void endDocument() override {}
  void setDocumentMetaData(const librevenge::RVNGPropertyList &) override {}
  void defineEmbeddedFont(const librevenge::RVNGPropertyList &) override {}
  void startPage(const librevenge::RVNGPropertyList &propList) override;
  void endPage() override {}
  void startMasterPage(const librevenge::RVNGPropertyList &) override { m_model.stats.masterPages++; }
  void endMasterPage() override {}
  void setStyle(const librevenge::RVNGPropertyList &propList) override { m_style = propList; }
  void startLayer(const librevenge::RVNGPropertyList &propList) override { openGroup(propList); }
  void endLayer() override { closeGroup(); }
  void startEmbeddedGraphics(const librevenge::RVNGPropertyList &) override {}
  void endEmbeddedGraphics() override {}
  void openGroup(const librevenge::RVNGPropertyList &) override;
  void closeGroup() override;
  void drawRectangle(const librevenge::RVNGPropertyList &propList) override;
  void drawEllipse(const librevenge::RVNGPropertyList &propList) override;
  void drawPolygon(const librevenge::RVNGPropertyList &propList) override { drawPoints(propList, true); }
  void drawPolyline(const librevenge::RVNGPropertyList &propList) override { drawPoints(propList, false); }
  void drawPath(const librevenge::RVNGPropertyList &propList) override;
  void drawGraphicObject(const librevenge::RVNGPropertyList &) override { m_model.stats.graphicObjects++; }
  void drawConnector(const librevenge::RVNGPropertyList &) override { m_model.stats.connectors++; }
  void startTextObject(const librevenge::RVNGPropertyList &) override { m_model.stats.textObjects++; }
  void endTextObject() override {}
  void startTableObject(const librevenge::RVNGPropertyList &) override {}
  void openTableRow(const librevenge::RVNGPropertyList &) override {}
  void closeTableRow() override {}
  void openTableCell(const librevenge::RVNGPropertyList &) override {}
  void closeTableCell() override {}
  void insertCoveredTableCell(const librevenge::RVNGPropertyList &) override {}
  void endTableObject() override {}
  void insertTab() override {}
  void insertSpace() override {}
  void insertText(const librevenge::RVNGString &) override {}
  void insertLineBreak() override {}
  void insertField(const librevenge::RVNGPropertyList &) override {}
  void openOrderedListLevel(const librevenge::RVNGPropertyList &) override {}
  void openUnorderedListLevel(const librevenge::RVNGPropertyList &) override {}
  void closeOrderedListLevel() override {}
  void closeUnorderedListLevel() override {}
  void openListElement(const librevenge::RVNGPropertyList &) override {}
  void closeListElement() override {}
  void defineParagraphStyle(const librevenge::RVNGPropertyList &) override {}
  void openParagraph(const librevenge::RVNGPropertyList &) override {}
  void closeParagraph() override {}
  void defineCharacterStyle(const librevenge::RVNGPropertyList &) override {}
  void openSpan(const librevenge::RVNGPropertyList &) override {}
  void closeSpan() override {}
  void openLink(const librevenge::RVNGPropertyList &) override {}
  void closeLink() override {}

private:
  Style currentStyle(const librevenge::RVNGPropertyList &shapeProps);
  void addPath(std::vector<SubPath> &&subPaths, const librevenge::RVNGPropertyList &shapeProps);
  void drawPoints(const librevenge::RVNGPropertyList &propList, bool closed);

  Model &m_model;
  librevenge::RVNGPropertyList m_style;
};

}  // namespace flyhand
