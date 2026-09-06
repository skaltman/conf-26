const path = require("node:path");
const pptxgen = require("pptxgenjs");

const pptx = new pptxgen();
const output = path.join(__dirname, "title-slide-visual-options.pptx");

pptx.layout = "LAYOUT_WIDE";
pptx.author = "Sara Altman and Simon Couch";
pptx.title = "Title slide visual options";
pptx.subject = "Two circles and abstract sunrise comparison";
pptx.theme = {
  headFontFace: "Avenir Next",
  bodyFontFace: "Avenir Next",
  lang: "en-US",
};

const colors = {
  green: "3A6945",
  cream: "FFF1C9",
  orange: "EF914C",
  periwinkle: "8393CF",
  gold: "F2C56D",
};

function addText(slide, value, options) {
  slide.addText(value, {
    fontFace: "Avenir Next",
    margin: 0,
    valign: "mid",
    ...options,
  });
}

function addTitleContent(slide) {
  slide.background = { color: colors.green };

  addText(slide, "Agents for correct,\ntransparent, and\nreproducible analysis", {
    x: 0.58,
    y: 1.2,
    w: 8.15,
    h: 3.15,
    fontSize: 48,
    bold: true,
    color: colors.cream,
    breakLine: true,
    fit: "shrink",
  });

  addText(slide, "Simon Couch and Sara Altman", {
    x: 0.7,
    y: 6.18,
    w: 4.4,
    h: 0.3,
    fontSize: 15,
    bold: true,
    color: colors.gold,
  });

  addText(slide, "posit::conf (2026)", {
    x: 0.7,
    y: 6.56,
    w: 3.1,
    h: 0.28,
    fontSize: 14,
    color: colors.gold,
  });
}

function addCircle(slide, x, color) {
  slide.addShape(pptx.ShapeType.ellipse, {
    x,
    y: 2.48,
    w: 1.95,
    h: 1.95,
    fill: { color },
    line: { color, transparency: 100 },
  });
}

function addSunrise(slide) {
  // The orange sun rises above a periwinkle horizon; the reflection keeps
  // both title concepts present without reading as two unrelated dots.
  slide.addShape(pptx.ShapeType.ellipse, {
    x: 9.92,
    y: 2.1,
    w: 2.25,
    h: 2.25,
    fill: { color: colors.orange },
    line: { color: colors.orange, transparency: 100 },
  });

  slide.addShape(pptx.ShapeType.rect, {
    x: 9.18,
    y: 3.24,
    w: 3.78,
    h: 1.75,
    fill: { color: colors.green },
    line: { color: colors.green, transparency: 100 },
  });

  const reflections = [
    { x: 9.2, y: 3.23, w: 3.72, h: 0.1 },
    { x: 9.55, y: 3.58, w: 3.02, h: 0.09 },
    { x: 9.92, y: 3.9, w: 2.28, h: 0.08 },
    { x: 10.3, y: 4.19, w: 1.52, h: 0.07 },
  ];

  for (const reflection of reflections) {
    slide.addShape(pptx.ShapeType.roundRect, {
      ...reflection,
      rectRadius: 0.04,
      fill: { color: colors.periwinkle },
      line: { color: colors.periwinkle, transparency: 100 },
    });
  }
}

const circles = pptx.addSlide();
addTitleContent(circles);
addCircle(circles, 9.05, colors.periwinkle);
addCircle(circles, 11.12, colors.orange);

const sunrise = pptx.addSlide();
addTitleContent(sunrise);
addSunrise(sunrise);

pptx.writeFile({ fileName: output });
