#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 shapeColor;
    vec2 itemSize;
    vec4 rectAv;
    vec4 rectBv;
    float cornerRadius;
    float blendK;
};

float sdRoundBox(vec2 p, vec2 center, vec2 halfSize, float r) {
    vec2 d = abs(p - center) - halfSize + r;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;
}

void main() {
    vec2 p = qt_TexCoord0 * itemSize;
    
    vec2 centerA = rectAv.xy + rectAv.zw * 0.5;
    vec2 centerB = rectBv.xy + rectBv.zw * 0.5;
    
    float dA = sdRoundBox(p, centerA, rectAv.zw * 0.5, cornerRadius);
    float dB = sdRoundBox(p, centerB, rectBv.zw * 0.5, cornerRadius);
    
    float dMin = min(dA, dB);
    
    float h = clamp(0.5 + 0.5 * (dB - dA) / blendK, 0.0, 1.0);
    float dSmooth = mix(dB, dA, h) - blendK * h * (1.0 - h);
    
    float dist = dMin;
    if (dA < blendK && dB < blendK) {
        dist = dSmooth;
    }
    
    float edge = fwidth(dist);
    float alpha = smoothstep(edge, -edge, dist);
    
    fragColor = shapeColor * alpha * qt_Opacity;
}
