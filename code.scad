// =====================================================
// CHASSI PARAMÉTRICO - ROBÔ COM ESP32 + HC-SR04 + 18650
// Ajustado para os módulos informados pelo usuário
// Todas as medidas em mm
// =====================================================
 
$fn = 64;
 
// -----------------------------------------------------
// CONFIGURAÇÕES GERAIS
// -----------------------------------------------------
mostrar_guias = true;     // true = mostra volumes de referência dos módulos
espessura     = 3.0;
prof_pocket   = 1.2;      // profundidade de rebaixo para encaixe
folga_encaixe = 0.8;      // folga total para componentes em encaixe
diam_m3       = 3.4;      // furo/rasgo para M3
diam_m2       = 2.4;
 
// -----------------------------------------------------
// CHASSI (definido para caber tudo)
// -----------------------------------------------------
chassi_L = 165;
chassi_W = 100;
raio_canto = 10;
 
// -----------------------------------------------------
// COMPONENTES (convertidos de cm para mm)
// -----------------------------------------------------
motorE_L = 69;
motorE_W = 35.5;
motorE_H = 21;
 
motorD_L = 61;
motorD_W = 35.6;
motorD_H = 22;
 
esp32_L = 69;
esp32_W = 50.9;
esp32_H = 11;
 
ponte_L = 41.5;
ponte_W = 41.5;
ponte_H = 27;
 
bat_L = 75;
bat_W = 40;
bat_H = 16;
 
sensor_L = 45;
sensor_W = 25;
sensor_H = 26;
 
// -----------------------------------------------------
// POSIÇÕES DOS COMPONENTES (centros)
// -----------------------------------------------------
// origem do modelo no canto inferior esquerdo do chassi
bat_cx    = 42;
bat_cy    = 24;
 
esp_cx    = 82;
esp_cy    = 73;
 
ponte_cx  = 104;
ponte_cy  = 25;
 
sensor_cx = 141;
sensor_cy = 50;
 
// slots genéricos para fixação dos motores nas laterais
motor_slot_x1 = 52;
motor_slot_x2 = 78;
motor_slot_yL = 8;               // lado inferior
motor_slot_yR = chassi_W - 8;    // lado superior
 
// -----------------------------------------------------
// MÓDULOS AUXILIARES 2D
// -----------------------------------------------------
module rounded_rect_2d(w, h, r) {
    hull() {
        translate([r, r])         circle(r = r);
        translate([w-r, r])       circle(r = r);
        translate([r, h-r])       circle(r = r);
        translate([w-r, h-r])     circle(r = r);
    }
}
 
module slot_2d(x, y, comprimento_slot, diametro_slot, angulo = 0) {
    translate([x, y])
    rotate(angulo)
    hull() {
        translate([-comprimento_slot/2, 0]) circle(d = diametro_slot);
        translate([ comprimento_slot/2, 0]) circle(d = diametro_slot);
    }
}
 
module hole_2d(x, y, d) {
    translate([x, y]) circle(d = d);
}
 
// -----------------------------------------------------
// MÓDULOS AUXILIARES 3D
// -----------------------------------------------------
module pocket_rounded(xc, yc, w, h, depth, r = 2) {
    translate([xc - w/2, yc - h/2, espessura - depth])
        linear_extrude(height = depth + 0.02)
            rounded_rect_2d(w, h, r);
}
 
module guia_componente(xc, yc, w, h, z, cor = [0,0,1,0.25]) {
    color(cor)
    translate([xc - w/2, yc - h/2, espessura])
        cube([w, h, z]);
}
 
// -----------------------------------------------------
// CONTORNO EXTERNO DO CHASSI
// Forma simples e funcional com frente arredondada
// -----------------------------------------------------
module contorno_chassi_2d() {
    union() {
        // corpo principal
        rounded_rect_2d(140, chassi_W, raio_canto);
 
        // frente arredondada
        translate([140, chassi_W/2])
            circle(r = 25);
    }
}
 
// -----------------------------------------------------
// FUROS E RASGOS PASSANTES
// -----------------------------------------------------
module cortes_passantes_2d() {
 
    // ==============================
    // MOTORES (rasgos ajustáveis)
    // ==============================
    // lado inferior
    slot_2d(motor_slot_x1, motor_slot_yL, 10, diam_m3, 0);
    slot_2d(motor_slot_x2, motor_slot_yL, 10, diam_m3, 0);
 
    // lado superior
    slot_2d(motor_slot_x1, motor_slot_yR, 10, diam_m3, 0);
    slot_2d(motor_slot_x2, motor_slot_yR, 10, diam_m3, 0);
 
    // ==============================
    // BATERIA (4 rasgos)
    // ==============================
    for (sx = [-1, 1], sy = [-1, 1]) {
        slot_2d(
            bat_cx + sx*(bat_L/2 - 10),
            bat_cy + sy*(bat_W/2 - 6),
            8,
            diam_m3,
            0
        );
    }
 
    // ==============================
    // ESP32 (4 rasgos)
    // ==============================
    for (sx = [-1, 1], sy = [-1, 1]) {
        slot_2d(
            esp_cx + sx*(esp32_L/2 - 9),
            esp_cy + sy*(esp32_W/2 - 7),
            6,
            diam_m3,
            0
        );
    }
 
    // ==============================
    // PONTE H (slots auxiliares p/ retenção)
    // ==============================
    slot_2d(ponte_cx - 16, ponte_cy, 10, diam_m3, 90);
    slot_2d(ponte_cx + 16, ponte_cy, 10, diam_m3, 90);
 
    // ==============================
    // SENSOR ULTRASSÔNICO
    // - furos dos transdutores
    // - furos pequenos laterais
    // ==============================
    hole_2d(sensor_cx - 13, sensor_cy, 16.5);
    hole_2d(sensor_cx + 13, sensor_cy, 16.5);
 
    hole_2d(sensor_cx - 20, sensor_cy, diam_m3);
    hole_2d(sensor_cx + 20, sensor_cy, diam_m3);
 
    // ==============================
    // PASSAGEM DE CABOS
    // ==============================
    slot_2d(92, 50, 14, 4.0, 90);     // passagem central
    slot_2d(120, 50, 10, 4.0, 90);    // passagem p/ sensor
    slot_2d(25, 50, 18, 4.0, 90);     // passagem traseira
}
 
// -----------------------------------------------------
// CHASSI FINAL
// -----------------------------------------------------
difference() {
 
    // placa base com furos passantes
    linear_extrude(height = espessura)
        difference() {
            contorno_chassi_2d();
            cortes_passantes_2d();
        }
 
    // -----------------------------------
    // REBAIXO / BERÇO DA PONTE H
    // -----------------------------------
    pocket_rounded(
        ponte_cx,
        ponte_cy,
        ponte_L + folga_encaixe,
        ponte_W + folga_encaixe,
        prof_pocket,
        2
    );
 
    // -----------------------------------
    // REBAIXO / BERÇO DO SENSOR
    // -----------------------------------
    pocket_rounded(
        sensor_cx,
        sensor_cy,
        sensor_L + folga_encaixe,
        sensor_W + folga_encaixe,
        prof_pocket,
        2
    );
}
 
// -----------------------------------------------------
// GUIAS VISUAIS DOS COMPONENTES (somente preview)
// -----------------------------------------------------
if (mostrar_guias) {
 
    // bateria
    guia_componente(
        bat_cx, bat_cy, bat_L, bat_W, bat_H,
        [1, 0, 0, 0.25]
    );
 
    // esp32
    guia_componente(
        esp_cx, esp_cy, esp32_L, esp32_W, esp32_H,
        [0, 0.6, 1, 0.25]
    );
 
    // ponte H
    guia_componente(
        ponte_cx, ponte_cy, ponte_L, ponte_W, ponte_H,
        [0, 1, 0.2, 0.25]
    );
 
    // sensor
    guia_componente(
        sensor_cx, sensor_cy, sensor_L, sensor_W, sensor_H,
        [1, 0.6, 0, 0.25]
    );
}