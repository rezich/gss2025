Header :: struct {
    head: [4] u8;
    offset: u32;
    size: u32;
}

Section :: struct {
    FILENAME_MAXLENGTH :: 56;
    name: [FILENAME_MAXLENGTH] u8;
    offset: u32;
    size: u32;
}

Error :: enum {
    NONE;
    IDENT_CORRUPT;
    HEADER_CORRUPT;
    OPEN;
    WRITE;
    READ;
    MALLOC;
    FILENAME_LENGTH;
    DUPLICATE_FILE;
    NOT_IMPLEMENTED;
}
