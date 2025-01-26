uniform vec2 step;

vec4 effect(vec4 col, Image texture, vec2 texturePos, vec2 screenPos) {
    float currentAlpha = Texel(texture, texturePos).a;

    // Calculate neighboring alpha values
    float alphaLeft = Texel(texture, texturePos + vec2(-step.x, 0.0)).a;
    float alphaRight = Texel(texture, texturePos + vec2(step.x, 0.0)).a;
    float alphaUp = Texel(texture, texturePos + vec2(0.0, -step.y)).a;
    float alphaDown = Texel(texture, texturePos + vec2(0.0, step.y)).a;

    // Determine if the current pixel is an edge on the **inside**
    if (currentAlpha > 0.0 && (alphaLeft == 0.0 || alphaRight == 0.0 || alphaUp == 0.0 || alphaDown == 0.0)) {
        // Apply inner border color (black, fully opaque in this example)
        return vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        // Default behavior: render the texture pixel as-is
        return Texel(texture, texturePos) * col;
    }
}