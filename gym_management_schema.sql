

CREATE TABLE trainers (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    qualifications TEXT NULL,
    specialization VARCHAR(150) NULL,
    working_hours VARCHAR(100) NULL,
    phone VARCHAR(30) NULL,
    email VARCHAR(254) NULL,
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_trainers_email (email),
    KEY idx_trainers_status (status)
) ENGINE=InnoDB;

-- History is retained when an assignment ends; only one active trainer per member.
CREATE TABLE trainer_assignments (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    member_id BIGINT UNSIGNED NOT NULL,
    trainer_id BIGINT UNSIGNED NOT NULL,
    assigned_at DATE NOT NULL DEFAULT (CURRENT_DATE),
    ended_at DATE NULL,
    notes TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_trainer_assignments_member
        FOREIGN KEY (member_id) REFERENCES members (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_trainer_assignments_trainer
        FOREIGN KEY (trainer_id) REFERENCES trainers (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_trainer_assignment_dates
        CHECK (ended_at IS NULL OR ended_at >= assigned_at),
    KEY idx_trainer_assignments_member (member_id),
    KEY idx_trainer_assignments_trainer (trainer_id),
    KEY idx_trainer_assignments_active (member_id, ended_at)
) ENGINE=InnoDB;

CREATE TABLE membership_plans (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    duration_months SMALLINT UNSIGNED NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT NULL,
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_membership_plans_name (name),
    CONSTRAINT chk_membership_plan_duration CHECK (duration_months > 0),
    CONSTRAINT chk_membership_plan_price CHECK (price >= 0),
    KEY idx_membership_plans_status (status)
) ENGINE=InnoDB;

-- Each row records one membership period, including renewals and plan changes.
CREATE TABLE member_plans (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    member_id BIGINT UNSIGNED NOT NULL,
    membership_plan_id BIGINT UNSIGNED NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    amount_paid DECIMAL(10, 2) NOT NULL,
    status ENUM('scheduled', 'active', 'expired', 'cancelled') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_member_plans_member
        FOREIGN KEY (member_id) REFERENCES members (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_member_plans_plan
        FOREIGN KEY (membership_plan_id) REFERENCES membership_plans (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_member_plan_dates CHECK (end_date >= start_date),
    CONSTRAINT chk_member_plan_amount CHECK (amount_paid >= 0),
    KEY idx_member_plans_member_dates (member_id, start_date, end_date),
    KEY idx_member_plans_status_end (status, end_date)
) ENGINE=InnoDB;

CREATE TABLE workout_plans (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(120) NOT NULL,
    description TEXT NULL,
    created_by_trainer_id BIGINT UNSIGNED NULL,
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_workout_plans_trainer
        FOREIGN KEY (created_by_trainer_id) REFERENCES trainers (id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    KEY idx_workout_plans_status (status),
    KEY idx_workout_plans_trainer (created_by_trainer_id)
) ENGINE=InnoDB;

-- A workout plan contains multiple exercises, optionally scheduled by day.
CREATE TABLE workout_plan_exercises (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    workout_plan_id BIGINT UNSIGNED NOT NULL,
    day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NULL,
    exercise_name VARCHAR(150) NOT NULL,
    sets TINYINT UNSIGNED NULL,
    reps TINYINT UNSIGNED NULL,
    sort_order SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    notes TEXT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_workout_exercises_plan
        FOREIGN KEY (workout_plan_id) REFERENCES workout_plans (id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_workout_exercise_sets CHECK (sets IS NULL OR sets > 0),
    CONSTRAINT chk_workout_exercise_reps CHECK (reps IS NULL OR reps > 0),
    KEY idx_workout_exercises_plan_order (workout_plan_id, sort_order)
) ENGINE=InnoDB;

-- Assignment history permits a member to receive updated plans over time.
CREATE TABLE member_workout_plans (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    member_id BIGINT UNSIGNED NOT NULL,
    workout_plan_id BIGINT UNSIGNED NOT NULL,
    assigned_by_trainer_id BIGINT UNSIGNED NULL,
    assigned_at DATE NOT NULL DEFAULT (CURRENT_DATE),
    ended_at DATE NULL,
    trainer_notes TEXT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_member_workout_plans_member
        FOREIGN KEY (member_id) REFERENCES members (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_member_workout_plans_plan
        FOREIGN KEY (workout_plan_id) REFERENCES workout_plans (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_member_workout_plans_trainer
        FOREIGN KEY (assigned_by_trainer_id) REFERENCES trainers (id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_member_workout_plan_dates
        CHECK (ended_at IS NULL OR ended_at >= assigned_at),
    KEY idx_member_workout_plans_member (member_id, assigned_at),
    KEY idx_member_workout_plans_plan (workout_plan_id)
) ENGINE=InnoDB;
