// SPDX-License-Identifier: MPL-2.0
// FlyHand: suite versions for Illustrator 25.1.
//
// The Illustrator 2021 SDK (v5) targets 25.4. These suites have a lower version in 25.1
// (measured on the MacPro6,1, see docs/suites-25.1.tsv). Include this file after the SDK
// headers and only call functions that already exist in the 25.1 version of each suite.
#pragma once

#undef  kAIUserSuiteVersion
#define kAIUserSuiteVersion            AIAPI_VERSION(18)
#undef  kAIArtboardSuiteVersion
#define kAIArtboardSuiteVersion        AIAPI_VERSION(4)
#undef  kAIDocumentViewSuiteVersion
#define kAIDocumentViewSuiteVersion    AIAPI_VERSION(14)
#undef  kAIRuntimeSuiteVersion
#define kAIRuntimeSuiteVersion         AIAPI_VERSION(13)
#undef  kAIAnnotatorDrawerSuiteVersion
#define kAIAnnotatorDrawerSuiteVersion AIAPI_VERSION(7)
// ATE GlyphRun: 2 in the SDK, 1 in 25.1 (FlyHand does not use it).
