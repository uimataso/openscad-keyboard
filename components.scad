socket_d =
    switch_type == "choc" ? [17.5, 16.5, 3.6]
    : [];

socket_x = socket_d.x;
socket_y = socket_d.y;
socket_z = socket_d.z;

module socket() {
    if (switch_type == "choc")
        choc_socket();
}

// Available values for x/y/z:
// 1 -> forward, 0 -> center, -1 -> backward
function socket_corner(x, y, z) =
    switch_type == "choc" ? choc_socket_corner(x, y, z)
    : [];


// Choc switch socket
module choc_socket() {
    inner_d = 13.8;
    frame_h = 2.2;

    notch_len = 0.7;
    notch_width = 3.7;
    notch_h = 0.9;
    notch_dist = 3.6;

    bottom_h = socket_z - frame_h;
    switch_center_hole_d = 3.4;
    switch_side_hole_d = 1.9;
    switch_side_hole_dist = 5.5;

    hot_socket_hole_d = 3.2;
    hot_socket_hole1_trans = [0, 5.9, 0];
    hot_socket_hole2_trans = [5, 3.8, 0];

    union() {
        // top frame
        translate([0, 0, bottom_h + notch_h])
        linear_extrude(height= frame_h - notch_h)
        difference() {
            square([socket_x, socket_y], center=true);
            square([inner_d, inner_d], center=true);
        };

        // top frame with notch
        translate([0, 0, bottom_h])
        linear_extrude(height=notch_h)
        difference() {
            square([socket_x, socket_y], center=true);
            square([inner_d, inner_d], center=true);
            for(i=[-1, 1], j=[-1, 1])
                translate([i * (inner_d + notch_len) / 2, j * notch_dist])
                    square([notch_len, notch_width], true);
        };

        // bottom
        linear_extrude(height=bottom_h)
        difference() {
            square([socket_x, socket_y], center=true);

            // switch center hole
            circle(d=switch_center_hole_d);

            // switch side hole
            for(i=[1, -1])
                translate([i * switch_side_hole_dist, 0, 0])
                    circle(d=switch_side_hole_d);

            // socket hole
            for(trans=[hot_socket_hole1_trans, hot_socket_hole2_trans])
                translate(-trans)
                    circle(d=hot_socket_hole_d);
        }
        if (show_switch) {
            translate([0, 0, socket_z + switch_h/2])
            color(switch_color)
                cube([socket_x, socket_y, switch_h], true);
        }
    }
}

function choc_socket_corner(x, y, z) = [
    x * socket_x / 2,
    y * socket_y / 2,
    (z + 1) / 2 * socket_z,
];
