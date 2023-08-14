// https://github.com/markedagain/neko/tree/master

game: struct {
    Mode :: enum { DEFAULT; BUILD; LOSE; WIN; PLAY; PAUSE; }
    mode_current: Mode;
    mode_last: Mode;
}


School :: struct {
    name: string;
    money: int;
    tuition: int;
    minimum_incoming_gpa: float;
    minimum_gpa: float;
    student_capacity: int;
    current_students: int;
    incoming_students: int;
    expected_graduates: int;
}


Student :: struct {
    Sex :: enum { MALE; FEMALE; }
    Major :: enum { TECH; ART; DESIGN; }

    sex: Sex;
    major: Major;
    traits: [3] string;
    skills: [#run enum_highest_value(Major)+1] int;
    skill_increase: [skills: [#run enum_highest_value(Major)+1] int;] float;
    head: int;
    face: int;
    hair: int;
    body: int;
    legs: int;
    gpa: float;
    motivation: int;
    life_modifier: int;
    year_started: int;
    semester_started: int;
    tuition: int;
    counter: int;
    graduated: bool;
}
