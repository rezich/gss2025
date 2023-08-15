Asset :: struct {
    data: *void;
    size: u32;
}

Sprite :: struct {
    asset: Asset;
    width: int = 32;
    height: int = 32;
    u: float = 0.5;
    v: float = 0.5;
}
Sound :: struct {
    asset: Asset;
}
Texture :: struct { //TODO: remove, just use Simp.Texture
    asset: Asset;
    width:  int;
    height: int;
    texture: Simp.Texture;
}
//Texture :: #type Simp.Texture;
Text_File :: #type [..] string;

assets: struct {
    pool: Flat_Pool;

    sprites:    Table(string, Sprite);
    sounds:     Table(string, Sound);
    textures:   Table(string, Texture);
    text_files: Table(string, Text_File);
}


Asset_Load_Report :: struct {
    total:      int;
    temporary:  int;
    skipped:    int;
    sprites:    int;
    sounds:     int;
    textures:   int;
    text_files: int;
}

load_assets :: () -> Asset_Load_Report {
    report: Asset_Load_Report;

    temp_assets: Table(string, Asset);
    temp_asset_pool: Flat_Pool;

    pak := pak_open("data.pak"); assert(pak_check(pak) == .NONE);
    sections := pak_get_sections(pak);
    for sections {
        filename := copy_string(to_string(*it.name[0], c_style_strlen(*it.name[0])));
        data_load_location: *void;
        if #complete how_asset_should_be_loaded(filename) == {
            case .NOT_AT_ALL;
                report.skipped += 1;
                continue;
            case .INTO_ASSET_STORAGE;
                data_load_location = get(*assets.pool, it.size);
            case .INTO_TEMP_STORAGE;
                data_load_location = get(*temp_asset_pool, it.size);
                report.temporary += 1;
        }
        pak_load_into(pak, it, data_load_location);
        load_asset(filename, Asset.{data=data_load_location, size=it.size}, *report);
        free(filename);
        report.total += 1;
    }
    array_free(sections);
    pak_close(pak);
    fini(*temp_asset_pool);
    deinit(*temp_assets);
    reset_temporary_storage();
    return report;
}

how_asset_should_be_loaded :: (name: string) -> enum { NOT_AT_ALL; INTO_ASSET_STORAGE; INTO_TEMP_STORAGE; } {
    if  ends_with(name, ".png") ||
        ends_with(name, ".wav") ||
        ends_with(name, ".mp3")
    then return .INTO_ASSET_STORAGE;

    if  ends_with(name, ".spr") ||
        ends_with(name, ".tex") ||
        ends_with(name, ".txt")
    then return .INTO_TEMP_STORAGE;

    return .NOT_AT_ALL;
}

load_asset :: (name: string, asset: Asset, report: *Asset_Load_Report) {
    make_key :: (name: string) -> string {
        found, _, name_with_extension := split_from_left(name, #char "/"); assert(found);
        return copy_string(path_strip_extension(name_with_extension));
    }

    if begins_with(name, "spr/") {
        if ends_with(name, ".spr") {
            //TODO
            report.sprites += 1;
        }
        else log("UNKNOWN FILETYPE IN spr/: %", name);
    }
    else if begins_with(name, "tex/") {
        if ends_with(name, ".tex") {
            texture_data_size := asset.size - size_of(u32) * 2;
            //TODO: actually load a texture from the RGBA values
            width : int = xx (cast(*u32) (asset.data)).*;
            height: int = xx (cast(*u32) (asset.data+size_of(u32))).*;

            texture := Texture.{
                asset=.{
                    data=get(*assets.pool, texture_data_size),
                    size=texture_data_size
                },
                width =width,
                height=height
            };
            memcpy(texture.asset.data, asset.data + size_of(u32) * 2, texture_data_size);
            added := table_add(*assets.textures, make_key(name), texture);

            bitmap := Simp.Bitmap.{
                width =xx width,
                height=xx height,
                mipmap_count=1,
                data=.[],
                stride=xx (width*4),
                flags=0,
                format=.RGBA8
            };
            bitmap.data.data = added.asset.data;
            bitmap.data.count = added.asset.size;

            success := Simp.texture_load_from_bitmap(*added.texture, *bitmap);
            assert(success);

            report.textures += 1;
        }
        else log("UNKNOWN FILETYPE IN tex/: %", name);
    }
    else if begins_with(name, "txt/") {
        if ends_with(name, ".txt") {
            text_file: Text_File;
            text_file.allocator = Allocator.{proc=flat_pool_allocator_proc, data = *assets.pool};

            for split(to_string(xx asset.data, asset.size), "\n", allocator=temp) array_add(*text_file, copy_string(trim(it, "\n"))); // bleh
            table_add(*assets.text_files, make_key(name), text_file);

            report.text_files += 1;
        }
        else log("UNKNOWN FILETYPE IN txt/: %", name);
    }
    else if begins_with(name, "sfx/") {
        if ends_with(name, ".mp3") {
            //TODO
            sound := Sound.{asset=asset};
            table_add(*assets.sounds, make_key(name), sound);
            report.sounds += 1;
        }
        else if ends_with(name, ".wav") {
            //TODO
            sound := Sound.{asset=asset};
            table_add(*assets.sounds, make_key(name), sound);
            report.sounds += 1;
        }
        else log("UNKNOWN FILETYPE IN sfx/: %", name);
    }
    else if begins_with(name, "bgm/") {
        if ends_with(name, ".mp3") {
            //TODO
            sound := Sound.{asset=asset};
            table_add(*assets.sounds, make_key(name), sound);
            report.sounds += 1;
        }
        else log("UNKNOWN FILETYPE IN bgm/: %", name);
    }
}

unload_assets :: () {
    for assets.sprites free(it_index);
    for assets.sounds free(it_index);
    for assets.text_files {
        for it free(it);
        free(it_index);
    }
    for assets.textures free(it_index);
    deinit(*assets.sprites);
    deinit(*assets.sounds);
    deinit(*assets.text_files);
    deinit(*assets.textures);
    fini(*assets.pool);
}

get_sprite      :: (name) => table_find_pointer(*assets.sprites,    name);
get_sound       :: (name) => table_find_pointer(*assets.sounds,     name);
get_texture     :: (name) => table_find_pointer(*assets.textures,   name);
get_text_file   :: (name) => table_find_pointer(*assets.text_files, name);

#load "Pak.jai";
