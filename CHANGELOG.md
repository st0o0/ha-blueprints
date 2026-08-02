# Changelog

## [0.1.3](https://github.com/st0o0/ha-blueprints/compare/v0.1.2...v0.1.3) (2026-08-02)


### Features

* add ADHD-friendly persistent reminder blueprint ([#8](https://github.com/st0o0/ha-blueprints/issues/8)) ([2045744](https://github.com/st0o0/ha-blueprints/commit/2045744c26d4a44384ef6902de91f5d6e5b4ab5a))
* add mobile notification with actions blueprint ([#10](https://github.com/st0o0/ha-blueprints/issues/10)) ([a0113bd](https://github.com/st0o0/ha-blueprints/commit/a0113bdbd6ab32a9186c5a81a8cba85abc539a9b))
* add robust Jinja2 templates and PR blueprint import links CI ([#6](https://github.com/st0o0/ha-blueprints/issues/6)) ([9db866b](https://github.com/st0o0/ha-blueprints/commit/9db866bd4b407d498bcad6319ece45f5f2909fa3))
* **adhd-reminder:** add 4 configurable time window sections ([34c3912](https://github.com/st0o0/ha-blueprints/commit/34c39125eda6cc2c31d7dcbab2555d4a1b16b722))
* **adhd-reminder:** add blueprint header, preset selector, notification inputs ([86b0a97](https://github.com/st0o0/ha-blueprints/commit/86b0a973f43737fd46e7f3a23f658231c3abaf99))
* **adhd-reminder:** add snooze and escalation settings ([64b66f0](https://github.com/st0o0/ha-blueprints/commit/64b66f030d15059aaae790d35658ce0707cbf4ae))
* **adhd-reminder:** add triggers, variables, and notification loop with escalation ([1c262ae](https://github.com/st0o0/ha-blueprints/commit/1c262ae958689c1238952728e79bb2d53778d4b9))
* **blueprints:** add double press, color mode, and robustness ([48760fb](https://github.com/st0o0/ha-blueprints/commit/48760fb083d4b2a67bdc7d11455f5be30ef861b7))
* **blueprints:** runtime color mode toggle and unified sections ([9d94199](https://github.com/st0o0/ha-blueprints/commit/9d941993eda85dbe60216b21566bebe4decf81f1))
* **E1743-light:** add color temp, night mode, hold invert, min brightness ([74e4734](https://github.com/st0o0/ha-blueprints/commit/74e473411bf8dd06af70f95e526ec6abb3309674))
* **E2001-light:** Store color mode with controller event ([740e0c5](https://github.com/st0o0/ha-blueprints/commit/740e0c577a6a9864a53667b097b5a80323cf2895))
* **Notification:** add mobile notification with actions blueprint ([54f10c4](https://github.com/st0o0/ha-blueprints/commit/54f10c4e45fe36af4c7054336eb29590907c2763))
* **Notification:** make timeout optional, default to no timeout ([4b09acf](https://github.com/st0o0/ha-blueprints/commit/4b09acfd7ba4d9ddce8201be459dd9640dbc5775))


### Bug Fixes

* **blueprints:** delay-free double press and config restructure ([45bc7cf](https://github.com/st0o0/ha-blueprints/commit/45bc7cf30e9f04a3749298f8b4ce5158be3db598))
* **ci:** only generate import links for changed blueprints in PR ([8842ff1](https://github.com/st0o0/ha-blueprints/commit/8842ff1ee184f55925d23e93b596bfb3489947ad))
* **ci:** use full clone depth for PR changed-file diff ([d653184](https://github.com/st0o0/ha-blueprints/commit/d653184306d28859775bd60209db13c06618dea0))
* correct helper_last_controller_event default type from [] to "" ([be3f41e](https://github.com/st0o0/ha-blueprints/commit/be3f41e9525b3d26483a915a61db224c28cf9af1))
* critical template bugs in ADHD reminder and default type corrections ([1e122ed](https://github.com/st0o0/ha-blueprints/commit/1e122ed062acac837c2a0b62ba66a13cd8799cb1))
* **E2001-light:** move light variable before color_mode to fix undefined error ([eeff106](https://github.com/st0o0/ha-blueprints/commit/eeff106a53fbbc5b8bb3b1ab092e5a1002ef381f))
* notification blueprint race condition, string-as-bool bugs, and default types ([93dcc5b](https://github.com/st0o0/ha-blueprints/commit/93dcc5b0a8567422a6c421624fe173493e3c34b4))
* **Notification:** wrap triggers input in list for schema validation ([2f9ab22](https://github.com/st0o0/ha-blueprints/commit/2f9ab22b19ef0a8564a1a5abf19d223ce1d918de))


### Refactoring

* **E2001-light:** move mode switch inputs to double press section ([42054ef](https://github.com/st0o0/ha-blueprints/commit/42054efb593d70b0bf4df707e851753e22d789f5))
* **E2001-light:** read color mode from light state, remove helper ([d0d957c](https://github.com/st0o0/ha-blueprints/commit/d0d957cd8d3ebf42c236d077da0d5d9bf2555eb9))

## [0.1.2](https://github.com/st0o0/ha-blueprints/compare/v0.1.1...v0.1.2) (2026-07-15)


### Features

* **blueprints:** Simplify color mode switching ([b70b4a0](https://github.com/st0o0/ha-blueprints/commit/b70b4a0f14d2930b0127406be57180904617b8ee))

## [0.1.1](https://github.com/st0o0/ha-blueprints/compare/v0.1.0...v0.1.1) (2026-07-15)


### Features

* **blueprints:** Improve IKEA remote blueprint descriptions ([f2b7860](https://github.com/st0o0/ha-blueprints/commit/f2b7860f39e2da216495d2485b79e531a597499a))

## 0.1.0 (2026-07-14)


### Features

* Add GitHub Actions for CI and releases ([0209806](https://github.com/st0o0/ha-blueprints/commit/0209806863304f5c30537f313f57167fae69dd04))
* Add GitHub Actions for CI and releases ([#2](https://github.com/st0o0/ha-blueprints/issues/2)) ([360d894](https://github.com/st0o0/ha-blueprints/commit/360d8943940a2704d2d5f15fbf291bfef7de62af))


### Bug Fixes

* remove trailing whitespace from all blueprints ([ba1e4cd](https://github.com/st0o0/ha-blueprints/commit/ba1e4cdff235f29ecc9f04f8c0db5d982f98eda1))
