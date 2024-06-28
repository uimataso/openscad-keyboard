// Apply multmatrix on a point.
// Input:
//   m : 4x4 or 4x3
//   v : 3
// Output : 3
function mult(m, v) = let (
    vm = concat(v, [1]), vt = m * vm
) [for (i=[0 : 2]) vt[i]];

function mapply(ms) =
    len(ms) == 0 ? 0 :
    len(ms) == 1 ? ms[0] :
    ms[0] * mapply([ for(i=[1 : len(ms)-1]) ms[i] ]);

function mtranslate(v) = [
    [1,  0,  0,  v.x],
    [0,  1,  0,  v.y],
    [0,  0,  1,  v.z],
    [0,  0,  0,    1]
];

function mrot_x(theta) = [
    [1,           0,            0,  0],
    [0,  cos(theta),  -sin(theta),  0],
    [0,  sin(theta),   cos(theta),  0],
    [0,           0,            0,  1]
];

function mrot_y(theta) = [
    [ cos(theta),  0,  sin(theta),  0],
    [          0,  1,           0,  0],
    [-sin(theta),  0,  cos(theta),  0],
    [          0,  0,           0,  1]
];

function mrot_z(theta) = [
    [cos(theta),  -sin(theta),  0,  0],
    [sin(theta),   cos(theta),  0,  0],
    [         0,            0,  1,  0],
    [         0,            0,  0,  1]
];

function mrotate(a) = mapply([
    mrot_z(a.z),
    mrot_y(a.y),
    mrot_x(a.x),
]);

function mrotate_ref(a, p) = mapply([
    mtranslate(p),
    mrotate(a),
    mtranslate(-p),
]);


// Display a point by sphere
module point(p, r=1, c="red", a=1) {
    translate(p)
    color(c, a)
        sphere(r);
}

// Same order as
// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids#polyhedron
module pillar(points) {
    n = len(points) / 2;
    faces = concat(
        [[ for (m=[0 : n - 1]) m ]], // bottom
        [[ for (m=[0 : n - 1]) 2 * n - 1 - m ]], // top
        [ for (m=[0 : n - 1]) [ // sides
            m,
            m + n,
            m + n + 1 == 2*n ? n : m + n + 1,
            m + 1 == n ? 0 : m + 1,
        ] ]
    );
    polyhedron(points, faces);
}
