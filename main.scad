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
// Number of keys on each columns.
main_key_nums = [3, 3, 3, 3, 2];
// Phi of each columns.
main_key_col_phis = [20, 20, 20, 20, 20];
// Translate of each columns.
main_key_col_trans = [[0, 4], [2, 4], [6, 0], [1, 2], [-7, 5]]; // [y, z]
// Gap between each columns.
main_key_col_gap = 2;
// Tilted of whole main keys.
main_key_whole_tilted = [-20, 10, 0];
// Translate of whole main keys.
main_key_whole_trans = [10, 20, 20];

// Thumb keys
// Number of thumb key.
thumb_key_num = 2;
// Phi of thumb key.
thumb_key_phi = 10;
// Theta of thumb key.
//thumb_key_theta = 20;
// Titled of thumb key.
thumb_key_tilted = [0, -40, 30];
// Translate of thumb key.
thumb_key_trans = [4, -3.5, 15];
// thumb_key_trans = [15, 0, 25]; // for thumb_key_num = 1;
// Nth key that thumb key attach with. Start with 1, 0 for no connection on side.
thumb_attach_side = 0;
// Nth key that thumb key attach with. Start with 1, must larger then 0.
thumb_attach_bottom = 2;


base_height = 7;
base_slope = 60;

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

        if (col < len(main_key_nums) - 1 && row < main_key_nums[col + 1]) {
            fill_row(row, col);
        }

        if (row < main_key_nums[col] - 1 && col < len(main_key_nums) - 1 && row < main_key_nums[col + 1] - 1) {
            fill_dia(row, col);
        }
    }
}

// THUMB KEY
function m_thumb_key_socket(n) = mapply([
    mtranslate(thumb_key_trans),
    mrotate(thumb_key_tilted),
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
            // Thumb top
            for (n=[0 : thumb_key_num - 1]) each [
                thumb_key_socket_corner(n, -1, 1, i),
                thumb_key_socket_corner(n,  1, 1, i),
            ],
            // Thumb right side
            thumb_key_socket_corner(thumb_key_num - 1, 1,  1, i),
            thumb_key_socket_corner(thumb_key_num - 1, 1, -1, i),

            // Main bottom
            for (col=[0 : thumb_attach_bottom - 1]) each [
                main_key_socket_corner(0, thumb_attach_bottom - 1 - col,  1, -1, i),
                main_key_socket_corner(0, thumb_attach_bottom - 1 - col, -1, -1, i),
            ],

            // Main left side
            each thumb_attach_side == 0 ? [] : [
                for (row=[0 : thumb_attach_side - 1]) each [
                    main_key_socket_corner(row, 0, -1, -1, i),
                    main_key_socket_corner(row, 0, -1,  1, i),
                ],
            ],
        ]
    ]);
}

module p2() {
    p = (thumb_key_socket_corner(0, 1, -1, 1) + thumb_key_socket_corner(1, -1, -1, 1)) / 2;
    p_dia = (thumb_key_socket_corner(0, 1, 1, 1) + thumb_key_socket_corner(1, -1, 1, 1)) / 2;

    p_down = thumb_key_socket_corner(0, 1, -1, -1);

    v = nnorm(nnorm(p - p_dia) - nnorm(p - p_down));
    point(p + temp_height * v);
}

module p3() {
    p = thumb_key_socket_corner(1, 1, -1, 1);
    p_dia = thumb_key_socket_corner(1, -1, 1, 1);
    p_down = thumb_key_socket_corner(1, 1, -1, -1);

    v = nnorm(nnorm(p - p_dia) - nnorm(p - p_down));
    point(p + temp_height * v);
}

module q1() {
    for (col=[thumb_attach_bottom - 1 : len(main_key_nums) - 2]) {
        p = (main_key_socket_corner(0, col, 1, -1, 1) + main_key_socket_corner(0, col + 1, -1, -1, 1)) / 2;
        p_dia = (main_key_socket_corner(0, col, 1, 1, 1) + main_key_socket_corner(0, col + 1, -1, 1, 1)) / 2;
        p_down = (main_key_socket_corner(0, col, 1, -1, -1) + main_key_socket_corner(0, col + 1, -1, -1, -1)) / 2;

        v = nnorm(nnorm(p - p_dia) - nnorm(p - p_down));

        point(p + temp_height * v);
    }
}

module q2() {
    col = len(main_key_nums) - 1;

    p = main_key_socket_corner(0, col, 1, -1, 1);
    p_dia = main_key_socket_corner(0, col, -1, 1, 1);
    p_down = main_key_socket_corner(0, col, 1, -1, -1);

    v = v_base(p, p_dia, p_down, 60);

    point(p + temp_height * v);
}

module base() {
    function thumb_corner(n, x, y) = let (
        p = thumb_key_socket_corner(n, x, y, 1),
        p_dia = thumb_key_socket_corner(n, -x, -y, 1),
        p_down = thumb_key_socket_corner(n, x, y, -1)
    )
        p + base_height * v_base(p, p_dia, p_down, base_slope);

    function thumb_x(n, y) = let (
        p = (thumb_key_socket_corner(n, 1, y, 1) + thumb_key_socket_corner(n + 1, -1, y, 1)) / 2,
        p_dia = (thumb_key_socket_corner(n, 1, -y, 1) + thumb_key_socket_corner(n + 1, -1, -y, 1)) / 2,
        p_down = (thumb_key_socket_corner(n, 1, y, -1) + thumb_key_socket_corner(n + 1, -1, y, -1)) / 2
    )
        p + base_height * v_base(p, p_dia, p_down, base_slope);

    function main_corner(row, col, x, y) = let (
        p      = main_key_socket_corner(row, col, x, y, 1),
        p_dia  = main_key_socket_corner(row, col, -x, -y, 1),
        p_down = main_key_socket_corner(row, col, x, y, -1)
    )
        p + base_height * v_base(p, p_dia, p_down, base_slope);

    function main_x(row, col, y) = let (
        p      = (main_key_socket_corner(row, col, 1, y, 1) + main_key_socket_corner(row, col + 1, -1, y, 1)) / 2,
        p_dia  = (main_key_socket_corner(row, col, 1, -y, 1) + main_key_socket_corner(row, col + 1, -1, -y, 1)) / 2,
        p_down = (main_key_socket_corner(row, col, 1, y, -1) + main_key_socket_corner(row, col + 1, -1, y, -1)) / 2
    )
        p + base_height * v_base(p, p_dia, p_down, base_slope);

    function main_y(row, col, x) = let (
        p      = (main_key_socket_corner(row, col, x, 1, 1) + main_key_socket_corner(row + 1, col, x, -1, 1)) / 2,
        p_dia  = (main_key_socket_corner(row, col, -x, -1, 1) + main_key_socket_corner(row + 1, col, -x, 1, 1)) / 2,
        p_down = (main_key_socket_corner(row, col, x, 1, -1) + main_key_socket_corner(row + 1, col, x, -1, -1)) / 2
    )
        p + base_height * v_base(p, p_dia, p_down, base_slope);


    point(thumb_corner(0, -1, -1));
    point(thumb_x(0, -1));
    point(thumb_corner(1, 1, -1));
    point(thumb_corner(0, -1, 1));

    for (col=[thumb_attach_bottom - 1 : len(main_key_nums) - 2]) {
        point(main_x(0, col, -1));
    }
    point(main_corner(0, len(main_key_nums) - 1, 1, -1));

    point(main_y(0, len(main_key_nums) - 1, 1));

    point(main_corner(1, len(main_key_nums) - 1, 1, 1));
}

function v_base(p, p1, p2, a) = let(v1 = nnorm(p - p1), v2 = nnorm(p - p2), f = a / 90)
    nnorm((1 - f) * v1 - f * v2);

base();

union() {
    main_key_sockets();
    thumb_key_sockets();
    main_thumb_key_connect();
}
