$fn = 32;

// Key switch type
switch_type = "choc";
// Key switch height
switch_h = 9;

// Show switch (cube) on top of choc socket
show_switch = false;
// Switch color
switch_color = "#888888";

include <lib.scad>
include <components.scad>

// Main keys
main_key_nums = [3, 3, 3, 3, 2];
main_key_col_phis = [20, 20, 20, 20, 20];
main_key_col_trans = [[2, 3], [2, 3], [5, 0], [2, 2], [0, 5]]; // [y, z]
main_key_col_gap = 2;
main_key_whole_tilted = [-20, 10, 0];
main_key_whole_trans = [10, 20, 20];

// Thumb keys
thumb_key_num = 2;
thumb_key_phi = 20;
thumb_key_theta = 20;
thumb_key_tilted = [0, -40, 0];
thumb_key_trans = [0, 0, 15];
thumb_attach_side = 1;
thumb_attach_bottom = 2;

// MAIN KEY
function m_main_key_socket(row, col) = let (phi = main_key_col_phis[col])
    mapply([
        mtranslate(main_key_whole_trans),
        mrotate(main_key_whole_tilted),
        mtranslate([
            col * (socket_x + main_key_col_gap),
            main_key_col_trans[col][0],
            main_key_col_trans[col][1]
        ]),
        mrotate_ref(
            [row * phi, 0, 0],
            [0, 0, switch_h + socket_z + (socket_y/2) * tan(90 - (phi/2))]
        ),
    ]);

function main_key_socket_corner(row, col, x, y, z) =
    mult(m_main_key_socket(row, col), socket_corner(x, y, z));

module main_key_sockets() {
    module fill_col(row, col) {
        pillar([
            for (i=[-1, 1]) each [
                main_key_socket_corner(row,   col, -1,  1, i),
                main_key_socket_corner(row,   col,  1,  1, i),
                main_key_socket_corner(row+1, col,  1, -1, i),
                main_key_socket_corner(row+1, col, -1, -1, i),
            ]
        ]);
    }

    module fill_row(row, col) {
        pillar([
            for (i=[-1, 1]) each [
                main_key_socket_corner(row, col,    1, -1, i),
                main_key_socket_corner(row, col+1, -1, -1, i),
                main_key_socket_corner(row, col+1, -1,  1, i),
                main_key_socket_corner(row, col,    1,  1, i),
            ]
        ]);
    }

    module fill_dia(row, col) {
        pillar([
            for (i=[-1, 1]) each [
                main_key_socket_corner(row,     col,  1,  1, i),
                main_key_socket_corner(row,   col+1, -1,  1, i),
                main_key_socket_corner(row+1, col+1, -1, -1, i),
                main_key_socket_corner(row+1,   col,  1, -1, i),
            ]
        ]);
    }

    for(col=[0 : len(main_key_nums) - 1], row=[0 : main_key_nums[col] - 1]) {
        multmatrix(m_main_key_socket(row, col)) socket();

        if (row < main_key_nums[col] - 1) {
            fill_col(row, col);
        }
        if (col < len(main_key_nums) - 1) {
            fill_row(row, col);
        }
        if (row < main_key_nums[col] - 1 && col < len(main_key_nums) - 1) {
            fill_dia(row, col);
        }
    }
}

// THUMB KEY
function m_thumb_key_socket(n) = mapply([
    mtranslate(thumb_key_trans),
    mrotate(thumb_key_tilted),
    // mrotate_ref(
    //     [0, 0, -n * thumb_key_theta],
    //     [socket_x/2, -socket_y/2, 0]
    // ),
    mrotate_ref(
        [0, n * thumb_key_phi, 0],
        [0, 0, -(socket_x/2) * tan(90 - (thumb_key_phi/2))]
    ),
]);

function thumb_key_socket_corner(n, x, y, z) =
    mult(m_thumb_key_socket(n), socket_corner(x, y, z));

module thumb_key_sockets() {
    for(n=[0 : thumb_key_num - 1])
        multmatrix(m_thumb_key_socket(n)) socket();

    if (thumb_key_num > 1) {
        for (n=[0 : thumb_key_num - 2]) {
            pillar( [ for (i=[-1, 1]) each [
                thumb_key_socket_corner(n,    1, -1, i),
                thumb_key_socket_corner(n+1, -1, -1, i),
                thumb_key_socket_corner(n+1, -1,  1, i),
                thumb_key_socket_corner(n,    1,  1, i),
            ]]);
        }
    }
}

module main_thumb_key_connect() {
    pillar([
        for (i=[-1, 1]) each [
            // thumb top
            for (n=[0 : thumb_key_num - 1]) each [
                thumb_key_socket_corner(n, -1, 1, i),
                thumb_key_socket_corner(n,  1, 1, i),
            ],
            // thumb right side
            thumb_key_socket_corner(thumb_key_num - 1, 1,  1, i),
            thumb_key_socket_corner(thumb_key_num - 1, 1, -1, i),
            // main bottom
            for (col=[0 : thumb_attach_bottom]) each [
                main_key_socket_corner(0, thumb_attach_bottom - col,  1, -1, i),
                main_key_socket_corner(0, thumb_attach_bottom - col, -1, -1, i),
            ],
            // main left side
            for (row=[0 : thumb_attach_side]) each [
                main_key_socket_corner(row, 0, -1, -1, i),
                main_key_socket_corner(row, 0, -1,  1, i),
            ]
        ]
    ]);
}

union() {
    main_key_sockets();
    thumb_key_sockets();
    main_thumb_key_connect();
}
