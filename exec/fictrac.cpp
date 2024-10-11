/// FicTrac http://rjdmoore.net/fictrac/
/// \file       fictrac.cpp
/// \brief      FicTrac program.
/// \author     Richard Moore
/// \copyright  CC BY-NC-SA 3.0

#include "Logger.h"
#include "Trackball.h"
#include "timing.h"
#include "misc.h"
#include "fictrac_version.h"

#include <string>
#include <csignal>
#include <memory>
#include <opencv2/opencv.hpp>  // Ensure OpenCV is included

using namespace std;
using namespace cv;  // Use OpenCV namespace

/// Ctrl-c handling
bool _active = true;
void ctrlcHandler(int /*signum*/) { _active = false; }


int main(int argc, char *argv[])
{
     PRINT("///");
     PRINT("/// FicTrac:\tA webcam-based method for generating fictive paths.\n///");
     PRINT("/// Usage:\tfictrac CONFIG_FN [-v LOG_VERBOSITY]\n///");
     PRINT("/// \tCONFIG_FN\tPath to input config file (defaults to config.txt).");
     PRINT("/// \tLOG_VERBOSITY\t[Optional] One of DBG, INF, WRN, ERR.");
     PRINT("///");
     PRINT("/// Version: %d.%d.%d (build date: %s)", FICTRAC_VERSION_MAJOR, FICTRAC_VERSION_MIDDLE, FICTRAC_VERSION_MINOR, __DATE__);
     PRINT("///\n");

	/// Parse args.
	string log_level = "info";
	string config_fn = "config.txt";
    bool do_stats = false;
	for (int i = 1; i < argc; ++i) {
		if ((string(argv[i]) == "--verbosity") || (string(argv[i]) == "-v")) {
			if (++i < argc) {
				log_level = argv[i];
			}
			else {
                LOG_ERR("-v/--verbosity requires one argument (debug < info (default) < warn < error)!");
				return -1;
			}
        }
        else if (string(argv[i]) == "--stats") {
            do_stats = true;
        }
        else {
            config_fn = argv[i];
		}
	}

    /// Set logging level.
    Logger::setVerbosity(log_level);

	// Catch cntl-c
    signal(SIGINT, ctrlcHandler);

	/// Set high priority (when run as SU).
    if (!SetProcessHighPriority()) {
        LOG_ERR("Error! Unable to set process priority!");
    } else {
        LOG("Set process priority to HIGH!");
    }

    unique_ptr<Trackball> tracker = make_unique<Trackball>(config_fn);

    /// Now Trackball has spawned our worker threads, we set this thread to low priority.
    SetThreadNormalPriority();

    /// Wait for tracking to finish.
    while (tracker->isActive()) {
        if (!_active) {
            tracker->terminate();
        }

        // Check if display is enabled and get the canvas
        if (tracker->isDisplayEnabled()) {  // Ensure this method exists in Trackball
            cv::Mat canvas = tracker->getCanvas();  // Ensure this method exists in Trackball
            if (!canvas.empty()) {
                cv::imshow("FicTrac-debug", canvas);
                uint16_t key = cv::waitKey(1);
                if (key == 0x1B) {  // esc
                    LOG("Exiting");
                    tracker->terminate();
                } else if (key == 0x52) { // shift+R
                    LOG("Resetting map!");
                    tracker->requestReset();  // Ensure this method exists in Trackball
                }
            }
        }

        ficsleep(250);
    }

    /// Save the eventual template to disk.
    tracker->writeTemplate();

    /// If we're running in test mode, print some stats.
    if (do_stats) {
        tracker->dumpStats();
    }

    /// Try to force release of all objects.
    tracker.reset();

    /// Wait a bit before exiting...
    ficsleep(250);

    //PRINT("\n\nHit ENTER to exit..");
    //getchar_clean();
    return 0;
}
