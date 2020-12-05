test_that("message appears",
          expect_message(shinyssd_run(),
               "Could not find directory. Try re-installing `shinyssd`."
))
