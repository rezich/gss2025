Pak :: struct {
    FILENAME_MAXLENGTH :: 56;
    Header :: struct {
        Head :: #type [4] u8;
        head: Head;
        offset: u32;
        size: u32;
    }
    Section :: struct {
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
    file: File;
    header: Header;
}

pak_open :: (filename: string) -> *Pak {
    pak := New(Pak);
    success: bool;

    pak.file, success = file_open(filename, log_errors = true);
    assert(success);

    success=, bytes_read := file_read(pak.file, *pak.header, size_of(Pak.Header));
    assert(success && bytes_read == size_of(Pak.Header));

    count := pak.header.size / size_of(Pak.Section);

    success = file_set_position(pak.file, pak.header.offset);
    assert(success);

    return pak;
}

pak_check :: (pak: *Pak) -> Pak.Error {
    if  pak.header.head[0] != #char "P" ||
        pak.header.head[1] != #char "A" ||
        pak.header.head[2] != #char "C" ||
        pak.header.head[3] != #char "K"
    then return .IDENT_CORRUPT;

    if  pak.header.offset < size_of(Pak.Header.Head) + 1 ||
        pak.header.size < 1
    then return .HEADER_CORRUPT;

    return .NONE;
}

pak_close :: (pak: *Pak) {
    file_close(*pak.file);
    free(pak);
}

pak_get_sections :: (pak: *Pak) -> [..] Pak.Section {
    count := pak.header.size / size_of(Pak.Section);

    sections: [..] Pak.Section;
    array_reserve(*sections, count);

    success := file_set_position(pak.file, pak.header.offset);
    assert(success);

    for 0..count-1 {
        section: Pak.Section;
        success=, bytes_read := file_read(pak.file, *section, size_of(Pak.Section));
        assert(success && bytes_read == size_of(Pak.Section));
        array_add(*sections, section);
    }
    return sections;
}

pak_load_into :: (pak: *Pak, section: Pak.Section, dest: *void) {
    success := file_set_position(pak.file, section.offset);
    assert(success);
    success=, bytes_read := file_read(pak.file, dest, section.size);
    assert(success && bytes_read == section.size);
}

#import "Basic";
#import "File";
