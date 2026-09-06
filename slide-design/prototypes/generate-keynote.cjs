const path = require("node:path");
const pptxgen = require("pptxgenjs");

const pptx = new pptxgen();
const root = __dirname;
const output = path.join(root, "prototype-slides-editable.pptx");
const hat = path.join(root, "assets", "cowboy-hat.png");

pptx.layout = "LAYOUT_WIDE";
pptx.author = "Sara Altman and Simon Couch";
pptx.subject = "Editable visual design prototypes";
pptx.title = "posit::conf(2026) slide design prototypes";
pptx.company = "Posit";
pptx.lang = "en-US";
pptx.theme = {
  headFontFace: "Avenir Next",
  bodyFontFace: "Avenir Next",
  lang: "en-US",
};
pptx.defineSlideMaster({
  title: "BLANK",
  background: { color: "F5F2EC" },
  objects: [],
  slideNumber: { x: 0, y: 0, color: "F5F2EC", transparency: 100 },
});

const C = {
  paper: "F5F2EC",
  warm: "FFF1C9",
  ink: "15243A",
  blue: "3F73D8",
  blueDark: "17447F",
  green: "43845A",
  greenDark: "2F673F",
  pink: "DD5D7B",
  pinkSoft: "FFC7D5",
  orange: "EF8B3E",
  gold: "FFD07A",
  mint: "59B899",
  mintDeep: "267D68",
  amber: "B57400",
  periwinkle: "8092D2",
  coralSoft: "FFAAA5",
};

const font = "Avenir Next";
const label = { x: 0.96, y: 0.72, w: 5.8, h: 0.3 };
const circle = { x: 9.65, y: 2.51, w: 2.48, h: 2.48 };

function text(slide, value, options) {
  slide.addText(value, {
    fontFace: font,
    margin: 0,
    breakLine: false,
    valign: "mid",
    ...options,
  });
}

function addLabel(slide, value, color) {
  text(slide, value, {
    ...label,
    fontSize: 14.25,
    bold: true,
    color,
    fit: "shrink",
  });
}

function addCircle(slide, color) {
  slide.addShape(pptx.ShapeType.ellipse, {
    ...circle,
    fill: { color },
    line: { color, transparency: 100 },
  });
}

function addLightSlide({ labelText, labelColor, circleColor, accentColor }) {
  const slide = pptx.addSlide("BLANK");
  slide.background = { color: C.paper };
  addLabel(slide, labelText, labelColor);

  text(slide, "Correctness can", {
    x: 0.96, y: 2.33, w: 7.5, h: 0.72,
    fontSize: 61.5, bold: true, color: C.ink,
    fit: "shrink",
  });
  slide.addText([
    { text: "be ", options: { color: C.ink } },
    { text: "convenient.", options: { color: accentColor } },
  ], {
    x: 0.96, y: 3.08, w: 7.55, h: 0.78,
    fontFace: font, fontSize: 61.5, bold: true,
    margin: 0, valign: "mid", breakLine: false, fit: "shrink",
  });
  text(slide, "Trustworthy data science in an age of agents", {
    x: 0.96, y: 4.28, w: 6.9, h: 0.38,
    fontSize: 18, color: "536071", fit: "shrink",
  });
  addCircle(slide, circleColor);
}

function addTalkSlide({ labelText, background, foreground, circleColor, labelColor = C.pinkSoft }) {
  const slide = pptx.addSlide("BLANK");
  slide.background = { color: background };
  addLabel(slide, labelText, labelColor);
  text(slide, "Agents for correct,\ntransparent, and\nreproducible analysis", {
    x: 0.96, y: 2.08, w: 7.45, h: 2.05,
    fontSize: 46.5, bold: true, color: foreground,
    breakLine: true, breakLineOnOverflow: false,
    fit: "shrink", valign: "mid",
  });
  text(slide, "Sara Altman and Simon Couch", {
    x: 0.96, y: 4.48, w: 5.8, h: 0.28,
    fontSize: 15.75, bold: true, color: C.gold,
  });
  text(slide, "posit::conf(2026)", {
    x: 0.96, y: 4.82, w: 3.6, h: 0.28,
    fontSize: 15.75, color: C.gold, transparency: 20,
  });
  addCircle(slide, circleColor);
}

function addSectionSlide({ labelText, background, foreground, heading, labelColor = C.pinkSoft }) {
  const slide = pptx.addSlide("BLANK");
  slide.background = { color: background };
  addLabel(slide, labelText, labelColor);
  const isLong = heading.length > 20;
  text(slide, isLong ? "1. \"Your VP is doing\nrogue analysis in cursor\"" : heading, {
    x: 0.96, y: isLong ? 2.45 : 2.77, w: 7.6, h: isLong ? 1.65 : 1.05,
    fontSize: isLong ? 42 : 78,
    bold: true,
    color: foreground,
    breakLine: true,
    fit: "shrink",
  });
  slide.addImage({
    path: hat,
    x: 9.57, y: 2.66, w: 2.71, h: 1.82,
  });
}

addLightSlide({
  labelText: "Blue pair / cool paper",
  labelColor: C.blueDark,
  circleColor: C.blue,
  accentColor: C.pink,
});
addLightSlide({
  labelText: "Accent test / mint + gold",
  labelColor: C.mintDeep,
  circleColor: C.mint,
  accentColor: C.amber,
});
addTalkSlide({
  labelText: "Accent test / periwinkle + coral",
  background: C.greenDark,
  foreground: C.warm,
  circleColor: C.periwinkle,
  labelColor: C.coralSoft,
});
addTalkSlide({
  labelText: "Blue pair / cool foreground",
  background: C.blueDark,
  foreground: C.paper,
  circleColor: C.orange,
});
addTalkSlide({
  labelText: "Blue pair / warm foreground",
  background: C.blueDark,
  foreground: C.warm,
  circleColor: C.orange,
});
addLightSlide({
  labelText: "Green pair / cool paper",
  labelColor: C.greenDark,
  circleColor: C.green,
  accentColor: C.pink,
});
addTalkSlide({
  labelText: "Green pair / cool foreground",
  background: C.greenDark,
  foreground: C.paper,
  circleColor: C.orange,
});
addTalkSlide({
  labelText: "Green pair / warm foreground",
  background: C.greenDark,
  foreground: C.warm,
  circleColor: C.orange,
});
addSectionSlide({
  labelText: "Section / periwinkle + coral",
  background: C.greenDark,
  foreground: C.warm,
  heading: "1. \"Your VP is doing rogue analysis in cursor\"",
  labelColor: C.coralSoft,
});
addSectionSlide({
  labelText: "Section / blue + cool foreground",
  background: C.blueDark,
  foreground: C.paper,
  heading: "1. The VP",
});
addSectionSlide({
  labelText: "Section / blue + warm foreground",
  background: C.blueDark,
  foreground: C.warm,
  heading: "1. The VP",
});
addSectionSlide({
  labelText: "Section / green + cool foreground",
  background: C.greenDark,
  foreground: C.paper,
  heading: "1. The VP",
});
addSectionSlide({
  labelText: "Section / green + warm foreground",
  background: C.greenDark,
  foreground: C.warm,
  heading: "1. The VP",
});

pptx.writeFile({ fileName: output });
