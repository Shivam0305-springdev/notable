-- USER SEQUENCE
create sequence if not exists
    seq_user_id as bigint
    increment by 1
    minvalue 0
    no maxvalue;

-- USER TABLE
CREATE TABLE if not exists users
(
    id          bigint default nextval('seq_user_id') primary key,
    displayName varchar(60)  not null,
    email       varchar(100) not null unique,
    password    varchar      not null,
    createdAt   timestamptz,
    updatedAt   timestamptz,
    isActive    bool
);

-- USER SEQUENCE AND USER TABLE OWNERSHIP
alter sequence seq_user_id owned by users.id;

-- RECORDINGS SEQUENCE
create sequence if not exists
    seq_rec_id as bigint
    increment by 1
    minvalue 0
    no maxvalue;

-- RECORDINGS TABLE
CREATE TABLE if not exists recordings
(
    id           bigint default nextval('seq_rec_id') primary key,
    user_id      bigint       not null,
    CONSTRAINT fk_rec_user_id
        FOREIGN KEY (user_id)
            REFERENCES users (id)
            on DELETE CASCADE,
    title        varchar(255) not null,
    subject      varchar(255) not null,
    audio_url    varchar(255) not null,
    duration_sec int,
    language     varchar(30),
    status       varchar(30),
    err_msg      varchar(255),
    created_at   timestamptz
);

alter sequence seq_rec_id owned by recordings.id;


-- TRANSCRIPTS SEQUENCE
create sequence if not exists
    seq_transcript_id as bigint
    increment by 1
    minvalue 0
    no maxvalue;

-- TRANSCRIPTS TABLE
CREATE TABLE if not exists transcripts
(
    id         bigint default nextval('seq_transcript_id') primary key,
    rec_id     bigint not null,
    CONSTRAINT fk_transcript_rec_id
        FOREIGN KEY (rec_id)
            REFERENCES recordings (id)
            on DELETE CASCADE,
    full_text  varchar(255),
    language   varchar(30),
    created_at timestamptz
);

alter sequence seq_transcript_id owned by transcripts.id;


-- NOTES SEQUENCE
create sequence if not exists
    seq_notes_id as bigint
    increment by 1
    minvalue 0
    no maxvalue;

-- NOTES TABLE
CREATE TABLE if not exists notes
(
    id         bigint default nextval('seq_notes_id') primary key,
    rec_id     bigint not null,
    CONSTRAINT fk_notes_rec_id
        FOREIGN KEY (rec_id)
            REFERENCES recordings (id)
            on DELETE CASCADE,
    user_id    bigint not null,
    CONSTRAINT fk_notes_user_id
        FOREIGN KEY (user_id)
            REFERENCES users (id)
            ON DELETE CASCADE,
    title      varchar(100),
    content_md varchar(1000),
    status     varchar(30),
    version    int,
    updated_at timestamptz,
    created_at timestamptz
);

alter sequence seq_notes_id owned by notes.id;

-- Each segment stores a timed portion of a transcript; IDs are generated independently.
create sequence if not exists
    seq_transcript_segment_id as bigint
    increment by 1
    minvalue 0
    no maxvalue;

-- Transcript text split into time-aligned segments for playback or highlighting.
CREATE TABLE if not exists transcript_segments
(
    id            bigint default nextval('seq_transcript_segment_id') primary key,
    transcript_id bigint not null,
    CONSTRAINT fk_transcript_segment_transcript_id
        FOREIGN KEY (transcript_id)
            REFERENCES transcripts (id)
            on DELETE CASCADE,
    start_ms      int,
    end_ms        int,
    text          text
);

alter sequence seq_transcript_segment_id owned by transcript_segments.id;

-- Each topic has its own generated ID and belongs to one note.
create sequence if not exists
    seq_note_topics_id as bigint
    increment by 1
    minvalue 0
    no maxvalue;

-- Key topics extracted from a note, optionally ranked and linked to a transcript position.
CREATE TABLE if not exists note_topics
(
    id         bigint default nextval('seq_note_topics_id') primary key,
    note_id    bigint not null,
    CONSTRAINT fk_note_topics_note_id
        FOREIGN KEY (note_id)
            REFERENCES notes (id)
            on DELETE CASCADE,
    topic      varchar(255),
    importance int,
    start_ms   int
);

alter sequence seq_note_topics_id owned by note_topics.id;

-- Diagrams are generated for notes and stored with their source representation.
create sequence if not exists
    seq_diagrams_id as bigint
    increment by 1
    minvalue 0
    no maxvalue;

-- Stores a note's Mermaid or SVG diagram and its generation status.
CREATE TABLE if not exists diagrams
(
    id           bigint default nextval('seq_diagrams_id') primary key,
    note_id      bigint not null,
    CONSTRAINT fk_diagrams_note_id
        FOREIGN KEY (note_id)
            REFERENCES notes (id)
            on DELETE CASCADE,
    diagram_type varchar(30),
    source_code  text,
    caption      varchar(255),
    status       varchar(30),
    created_at   timestamptz
);

alter sequence seq_diagrams_id owned by diagrams.id;

-- Each quiz has a generated ID and belongs to one note.
create sequence if not exists
    seq_quizzes_id as bigint
    increment by 1
    minvalue 0
    no maxvalue;

-- Quiz settings and generation state for questions based on a note.
CREATE TABLE if not exists quizzes
(
    id            bigint default nextval('seq_quizzes_id') primary key,
    note_id       bigint not null,
    CONSTRAINT fk_quizzes_note_id
        FOREIGN KEY (note_id)
            REFERENCES notes (id)
            on DELETE CASCADE,
    title         varchar(255),
    num_questions int,
    difficulty    varchar(30),
    question_type varchar(30),
    status        varchar(30),
    version       int,
    created_at    timestamptz
);

alter sequence seq_quizzes_id owned by quizzes.id;

-- Each question has a generated ID and belongs to one quiz.
create sequence if not exists
    seq_quiz_questions_id as bigint
    increment by 1
    minvalue 0
    no maxvalue;

-- Stores each quiz question, its JSON options, correct option, and explanation.
CREATE TABLE if not exists quiz_questions
(
    id             bigint default nextval('seq_quiz_questions_id') primary key,
    quiz_id        bigint not null,
    CONSTRAINT fk_quiz_questions_quiz_id
        FOREIGN KEY (quiz_id)
            REFERENCES quizzes (id)
            on DELETE CASCADE,
    question       text,
    options        json,
    correct_option int,
    explanation    text
);

alter sequence seq_quiz_questions_id owned by quiz_questions.id;

-- Each export has a generated ID and belongs to one note.
create sequence if not exists
    seq_exports_id as bigint
    increment by 1
    minvalue 0
    no maxvalue;

-- Tracks generated note files and their format, style, status, and download URL.
CREATE TABLE if not exists exports
(
    id         bigint default nextval('seq_exports_id') primary key,
    note_id    bigint not null,
    CONSTRAINT fk_exports_note_id
        FOREIGN KEY (note_id)
            REFERENCES notes (id)
            on DELETE CASCADE,
    format     varchar(30),
    font_style varchar(100),
    status     varchar(30),
    file_url   varchar(255),
    created_at timestamptz
);

alter sequence seq_exports_id owned by exports.id;
