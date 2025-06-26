local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- Debug Log Entry
  s("zdebug", {
    t("## 🐞 Debug Log"), t({ "", "- File: " }), i(1),
    t({ "", "- Symptom: " }), i(2),
    t({ "", "- Reproduction: " }), i(3),
    t({ "", "- Hypothesis: " }), i(4),
    t({ "", "- Notes: " }), i(5),
  }),

  -- Reference Link Entry
  s("zref", {
    t("## 🔗 Reference Note"), t({ "", "- Topic: " }), i(1),
    t({ "", "- Link: " }), i(2),
    t({ "", "- Why it matters: " }), i(3),
  }),

  -- Experimental Note
  s("zexp", {
    t("## 🔬 Experiment Log"), t({ "", "- Title: " }), i(1),
    t({ "", "- Date: " }), i(2),
    t({ "", "- Hypothesis: " }), i(3),
    t({ "", "- Method: " }), i(4),
    t({ "", "- Result: " }), i(5),
    t({ "", "- Interpretation: " }), i(6),
  }),
  -- Design Sketch
  s("zsketch", {
    t("## 📝 Design Sketch"), t({ "", "- Title: "}), i(1),
    t({"", "- Date: "}), i(2),
    t({"", "- Problem: "}), i(3),
    t({"", "- Scope: "}), i(4),
    t({"", "- Proposal: "}), i(5),
    t({"", "- Design: "}), i(6),
  })
}

