//
//  ROMCalculator.swift
//  WorkOutputTracker
//
//  Created by Reid on 5/27/25.
//


import Foundation

struct ROMCalculator {

    // MARK: - SQUAT-BASED MOVEMENTS

    /// Vertical bar travel in feet for squats/thrusters/wall balls/etc.
    static func squatROMInFeet(profile: UserProfile) -> Double {
        // Use user's leg length if available, else estimate as 46% (male) or 45% (female) of height.
        let legInInches: Double
        if let custom = profile.legLength {
            legInInches = profile.units == "Metric" ? custom / 2.54 : custom
        } else {
            let ratio = (profile.sex == "Female") ? 0.45 : 0.46
            let heightInInches = profile.units == "Metric" ? profile.height / 2.54 : profile.height
            legInInches = heightInInches * ratio
        }
        // 65% of leg length: estimated barbell vertical displacement in a squat to parallel depth, based on user’s leg length
        let romInInches = legInInches * 0.66
        return romInInches / 12.0
    }
    
    // MARK: - DEADLIFT

    /// Barbell vertical travel in feet for deadlift
    static func deadliftROMInFeet(profile: UserProfile) -> Double {
        // Bar moves from mid-shin (floor) to standing hip. Estimate as 70% of leg length, but bar starts lower than a squat.
        let legInInches: Double
        if let custom = profile.legLength {
            legInInches = profile.units == "Metric" ? custom / 2.54 : custom
        } else {
            let ratio = (profile.sex == "Female") ? 0.45 : 0.46
            let heightInInches = profile.units == "Metric" ? profile.height / 2.54 : profile.height
            legInInches = heightInInches * ratio
        }
        // Deadlift ROM ≈ 75% of leg length (longer than squat because bar starts at floor)
        let romInInches = legInInches * 0.75
        return romInInches / 12.0
    }
    
    // MARK: - BENCH PRESS

    /// Barbell vertical travel in feet for bench press (chest to lockout)
    static func benchROMInFeet(profile: UserProfile) -> Double {
        // Upper arm + forearm. If no arm length in profile, estimate 36% of height.
        let armInInches: Double
        if let custom = profile.armLength {
            armInInches = profile.units == "Metric" ? custom / 2.54 : custom
        } else {
            let ratio = (profile.sex == "Female") ? 0.35 : 0.36
            let heightInInches = profile.units == "Metric" ? profile.height / 2.54 : profile.height
            armInInches = heightInInches * ratio
        }
        // Bar travels about 75% of arm length in a good bench press
        let romInInches = armInInches * 0.75
        return romInInches / 12.0
    }

    // MARK: - SHOULDER-TO-OVERHEAD (PRESS, JERK, THRUSTER TOP HALF)
    static func pressROMInFeet(profile: UserProfile) -> Double {
        // Bar travels from shoulders to full overhead. Estimate as 85% of arm length.
        let armInInches: Double
        if let custom = profile.armLength {
            armInInches = profile.units == "Metric" ? custom / 2.54 : custom
        } else {
            let ratio = (profile.sex == "Female") ? 0.35 : 0.36
            let heightInInches = profile.units == "Metric" ? profile.height / 2.54 : profile.height
            armInInches = heightInInches * ratio
        }
        let romInInches = armInInches * 0.85
        return romInInches / 12.0
    }
    
    // MARK: - WALL BALL (SQUAT + THROW)
    static func wallBallROMInFeet(profile: UserProfile, targetHeight: Double = 10.0) -> Double {
        // Squat ROM + ball travels to target
        let squatROM = squatROMInFeet(profile: profile)
        // Add vertical from standing to target
        // If user provides actual throw height, use that. Else default 10 ft
        return squatROM + max(targetHeight - (profile.height / 12.0), 0)
    }

    // MARK: - SNATCH, CLEAN, CLEAN & JERK
    static func cleanAndJerkROMInFeet(profile: UserProfile) -> Double {
        let heightInInches = profile.units == "Metric" ? profile.height / 2.54 : profile.height
        let romInInches = heightInInches * 0.97
        return romInInches / 12.0
    }
    /// For snatch, decrease by 3% compared to clean & jerk to account for wider grip and lower lockout position.
    /// Snatch: bar travels from floor to fully overhead
    static func snatchROMInFeet(profile: UserProfile) -> Double {
        let heightInInches = profile.units == "Metric" ? profile.height / 2.54 : profile.height
        let romInInches = heightInInches * 0.94 // 3% less than C&J
        return romInInches / 12.0
    }
    // Floor to shoulder (clean phase)
    static func cleanROMInFeet(profile: UserProfile) -> Double {
        let heightInInches = profile.units == "Metric" ? profile.height / 2.54 : profile.height
        let romInInches = heightInInches * 0.81
        return romInInches / 12.0
    }

    // MARK: - THRUSTER
    /// Squat ROM + press ROM (shoulder to overhead)
    static func thrusterROMInFeet(profile: UserProfile) -> Double {
        return squatROMInFeet(profile: profile) + pressROMInFeet(profile: profile)
    }

    // MARK: - BURPEE
    /// Estimate vertical displacement per burpee as height from chest to standing
    static func burpeeROMInFeet(profile: UserProfile) -> Double {
        // Estimate as 60% of leg length (floor to standing)
        let legInInches: Double
        if let custom = profile.legLength {
            legInInches = profile.units == "Metric" ? custom / 2.54 : custom
        } else {
            let ratio = (profile.sex == "Female") ? 0.45 : 0.46
            let heightInInches = profile.units == "Metric" ? profile.height / 2.54 : profile.height
            legInInches = heightInInches * ratio
        }
        let romInInches = legInInches * 0.6
        return romInInches / 12.0
    }

    // MARK: - BOX JUMP
    /// Actual box height (user input) = ROM
    static func boxJumpROMInFeet(boxHeight: Double, units: String) -> Double {
        // boxHeight: user input (in inches or cm or ft depending on units)
        if units == "Metric" {
            return boxHeight * 0.0328084 // cm to feet
        } else {
            return boxHeight / 12.0 // inches to feet
        }
    }

    // MARK: - AbMat Sit-up
    /// Estimated vertical ROM for AbMat sit-up (shoulders from floor to over hips): ~12% of standing height
    static func abMatSitUpROMInFeet(profile: UserProfile) -> Double {
        let heightInInches = profile.units == "Metric" ? profile.height / 2.54 : profile.height
        let romInInches = heightInInches * 0.12
        return romInInches / 12.0
    }

    // MARK: - GHD Sit-up
    /// Estimated vertical ROM for competition GHD sit-up: 33% of standing height (shoulders/fingertips touch floor, full sit-up)
    static func ghdSitUpCompetitionROMInFeet(profile: UserProfile) -> Double {
        let heightInInches = profile.units == "Metric" ? profile.height / 2.54 : profile.height
        let romInInches = heightInInches * 0.33
        return romInInches / 12.0
    }

    // MARK: - Toes-to-Bar
    /// Estimated vertical ROM for toes-to-bar (feet from hang to bar): 70% of leg length (leg = 46% of height male, 45% female)
    static func toesToBarROMInFeet(profile: UserProfile) -> Double {
        let legInInches: Double
        if let custom = profile.legLength {
            legInInches = profile.units == "Metric" ? custom / 2.54 : custom
        } else {
            let ratio = (profile.sex == "Female") ? 0.45 : 0.46
            let heightInInches = profile.units == "Metric" ? profile.height / 2.54 : profile.height
            legInInches = heightInInches * ratio
        }
        let romInInches = legInInches * 0.7 // More realistic than 0.85
        return romInInches / 12.0
    }

    // MARK: - Muscle-up (bar or ring)
    /// Estimated vertical ROM for muscle-up: pull-up ROM + dip ROM + transition (25% of arm length)
    static func muscleUpROMInFeet(profile: UserProfile) -> Double {
        return pullUpROMInFeet(profile: profile)
            + dipROMInFeet(profile: profile)
            + transitionROMInFeet(profile: profile)
    }

    /// Transition phase for muscle-up: 25% of arm length
    static func transitionROMInFeet(profile: UserProfile) -> Double {
        let armInInches: Double
        if let custom = profile.armLength {
            armInInches = profile.units == "Metric" ? custom / 2.54 : custom
        } else {
            let ratio = (profile.sex == "Female") ? 0.35 : 0.36
            let heightInInches = profile.units == "Metric" ? profile.height / 2.54 : profile.height
            armInInches = heightInInches * ratio
        }
        let romInInches = armInInches * 0.25
        return romInInches / 12.0
    }

    // MARK: - Supporting Functions (If not already present)
    static func pullUpROMInFeet(profile: UserProfile) -> Double {
        let armInInches: Double
        if let custom = profile.armLength {
            armInInches = profile.units == "Metric" ? custom / 2.54 : custom
        } else {
            let ratio = (profile.sex == "Female") ? 0.35 : 0.36
            let heightInInches = profile.units == "Metric" ? profile.height / 2.54 : profile.height
            armInInches = heightInInches * ratio
        }
        let romInInches = armInInches * 0.60
        return romInInches / 12.0
    }

    static func dipROMInFeet(profile: UserProfile) -> Double {
        let armInInches: Double
        if let custom = profile.armLength {
            armInInches = profile.units == "Metric" ? custom / 2.54 : custom
        } else {
            let ratio = (profile.sex == "Female") ? 0.35 : 0.36
            let heightInInches = profile.units == "Metric" ? profile.height / 2.54 : profile.height
            armInInches = heightInInches * ratio
        }
        let romInInches = armInInches * 0.45
        return romInInches / 12.0
    }

    // MARK: - JUMP ROPE (Double Under, Single Under)
    static func jumpRopeROMInFeet(profile: UserProfile) -> Double {
        // Rough estimate: 1 foot (actual vertical travel of mass center per jump)
        return 1.0
    }
    
    // MARK: - RUNNING, ROWING, CYCLING, ETC.
    /// For monostructural movements, ROM is distance per rep (meters or feet), user input

    // MARK: - GENERIC/DEFAULT (For unsupported or user-defined movements)
    static func defaultROMInFeet(profile: UserProfile) -> Double {
        // Use an average ROM; you can make this more sophisticated as needed
        return 1.5 // fallback: 1.5 feet
    }
}
