"//\n"
"//   Copyright 2013 Pixar\n"
"//\n"
"//   Licensed under the Apache License, Version 2.0 (the \"Apache License\")\n"
"//   with the following modification; you may not use this file except in\n"
"//   compliance with the Apache License and the following modification to it:\n"
"//   Section 6. Trademarks. is deleted and replaced with:\n"
"//\n"
"//   6. Trademarks. This License does not grant permission to use the trade\n"
"//      names, trademarks, service marks, or product names of the Licensor\n"
"//      and its affiliates, except as required to comply with Section 4(c) of\n"
"//      the License and to reproduce the content of the NOTICE file.\n"
"//\n"
"//   You may obtain a copy of the Apache License at\n"
"//\n"
"//       http://www.apache.org/licenses/LICENSE-2.0\n"
"//\n"
"//   Unless required by applicable law or agreed to in writing, software\n"
"//   distributed under the Apache License with the above modification is\n"
"//   distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY\n"
"//   KIND, either express or implied. See the Apache License for the specific\n"
"//   language governing permissions and limitations under the Apache License.\n"
"//\n"
"\n"
"#if defined(SHADING_VARYING_COLOR) || defined(SHADING_FACEVARYING_COLOR)\n"
"#undef OSD_USER_VARYING_DECLARE\n"
"#define OSD_USER_VARYING_DECLARE "
"    vec3 color;\n"
"\n"
"#undef OSD_USER_VARYING_ATTRIBUTE_DECLARE\n"
"#define OSD_USER_VARYING_ATTRIBUTE_DECLARE "
"    layout(location = 1) in vec3 color;\n"
"\n"
"#undef OSD_USER_VARYING_PER_VERTEX\n"
"#define OSD_USER_VARYING_PER_VERTEX() "
"    outpt.color = color\n"
"\n"
"#undef OSD_USER_VARYING_PER_CONTROL_POINT\n"
"#define OSD_USER_VARYING_PER_CONTROL_POINT(ID_OUT, ID_IN) "
"    outpt[ID_OUT].color = inpt[ID_IN].color\n"
"\n"
"#undef OSD_USER_VARYING_PER_EVAL_POINT\n"
"#define OSD_USER_VARYING_PER_EVAL_POINT(UV, a, b, c, d) "
"    outpt.color = "
"        mix(mix(inpt[a].color, inpt[b].color, UV.x), "
"            mix(inpt[c].color, inpt[d].color, UV.x), UV.y)\n"
"\n"
"#undef OSD_USER_VARYING_PER_EVAL_POINT_TRIANGLE\n"
"#define OSD_USER_VARYING_PER_EVAL_POINT_TRIANGLE(UV, a, b, c) "
"    outpt.color = "
"        inpt[a].color * (1.0f - UV.x - UV.y) + "
"        inpt[b].color * UV.x + "
"        inpt[c].color * UV.y;\n"
"#else\n"
"#define OSD_USER_VARYING_DECLARE\n"
"#define OSD_USER_VARYING_ATTRIBUTE_DECLARE\n"
"#define OSD_USER_VARYING_PER_VERTEX()\n"
"#define OSD_USER_VARYING_PER_CONTROL_POINT(ID_OUT, ID_IN)\n"
"#define OSD_USER_VARYING_PER_EVAL_POINT(UV, a, b, c, d)\n"
"#define OSD_USER_VARYING_PER_EVAL_POINT_TRIANGLE(UV, a, b, c)\n"
"#endif\n"
"\n"
"//--------------------------------------------------------------\n"
"// Uniforms / Uniform Blocks\n"
"//--------------------------------------------------------------\n"
"\n"
"layout(std140) uniform Transform {\n"
"    mat4 ModelViewMatrix;\n"
"    mat4 ProjectionMatrix;\n"
"    mat4 ModelViewProjectionMatrix;\n"
"    mat4 ModelViewInverseMatrix;\n"
"};\n"
"\n"
"layout(std140) uniform Tessellation {\n"
"    float TessLevel;\n"
"};\n"
"\n"
"uniform int GregoryQuadOffsetBase;\n"
"uniform int PrimitiveIdBase;\n"
"\n"
"//--------------------------------------------------------------\n"
"// Osd external functions\n"
"//--------------------------------------------------------------\n"
"\n"
"mat4 OsdModelViewMatrix()\n"
"{\n"
"    return ModelViewMatrix;\n"
"}\n"
"mat4 OsdProjectionMatrix()\n"
"{\n"
"    return ProjectionMatrix;\n"
"}\n"
"mat4 OsdModelViewProjectionMatrix()\n"
"{\n"
"    return ModelViewProjectionMatrix;\n"
"}\n"
"float OsdTessLevel()\n"
"{\n"
"    return TessLevel;\n"
"}\n"
"int OsdGregoryQuadOffsetBase()\n"
"{\n"
"    return GregoryQuadOffsetBase;\n"
"}\n"
"int OsdPrimitiveIdBase()\n"
"{\n"
"    return PrimitiveIdBase;\n"
"}\n"
"int OsdBaseVertex()\n"
"{\n"
"    return 0;\n"
"}\n"
"\n"
"//--------------------------------------------------------------\n"
"// Vertex Shader\n"
"//--------------------------------------------------------------\n"
"#ifdef VERTEX_SHADER\n"
"\n"
"layout (location=0) in vec4 position;\n"
"OSD_USER_VARYING_ATTRIBUTE_DECLARE\n"
"\n"
"out block {\n"
"    OutputVertex v;\n"
"#ifdef OSD_PATCH_ENABLE_SINGLE_CREASE\n"
"    vec2 vSegments;\n"
"#endif\n"
"    OSD_USER_VARYING_DECLARE\n"
"} outpt;\n"
"\n"
"void main()\n"
"{\n"
"    outpt.v.position = ModelViewMatrix * position;\n"
"    outpt.v.patchCoord = vec4(0);\n"
"#ifdef OSD_PATCH_ENABLE_SINGLE_CREASE\n"
"    outpt.vSegments = vec2(0);\n"
"#endif\n"
"    OSD_USER_VARYING_PER_VERTEX();\n"
"}\n"
"\n"
"#endif\n"
"\n"
"//--------------------------------------------------------------\n"
"// Geometry Shader\n"
"//--------------------------------------------------------------\n"
"#ifdef GEOMETRY_SHADER\n"
"\n"
"#ifdef PRIM_QUAD\n"
"\n"
"    layout(lines_adjacency) in;\n"
"\n"
"    #define EDGE_VERTS 4\n"
"\n"
"#endif // PRIM_QUAD\n"
"\n"
"#ifdef  PRIM_TRI\n"
"\n"
"    layout(triangles) in;\n"
"\n"
"    #define EDGE_VERTS 3\n"
"\n"
"#endif // PRIM_TRI\n"
"\n"
"\n"
"layout(triangle_strip, max_vertices = EDGE_VERTS) out;\n"
"in block {\n"
"    OutputVertex v;\n"
"#ifdef OSD_PATCH_ENABLE_SINGLE_CREASE\n"
"    vec2 vSegments;\n"
"#endif\n"
"    OSD_USER_VARYING_DECLARE\n"
"} inpt[EDGE_VERTS];\n"
"\n"
"out block {\n"
"    OutputVertex v;\n"
"    noperspective out vec4 edgeDistance;\n"
"#ifdef OSD_PATCH_ENABLE_SINGLE_CREASE\n"
"    vec2 vSegments;\n"
"#endif\n"
"    OSD_USER_VARYING_DECLARE\n"
"} outpt;\n"
"\n"
"uniform isamplerBuffer OsdFVarParamBuffer;\n"
"layout(std140) uniform OsdFVarArrayData {\n"
"    OsdPatchArray fvarPatchArray[2];\n"
"};\n"
"\n"
"vec2\n"
"interpolateFaceVarying(vec2 uv, int fvarOffset)\n"
"{\n"
"    int patchIndex = OsdGetPatchIndex(gl_PrimitiveID);\n"
"\n"
"    OsdPatchArray array = fvarPatchArray[0];\n"
"\n"
"    ivec3 fvarPatchParam = texelFetch(OsdFVarParamBuffer, patchIndex).xyz;\n"
"    OsdPatchParam param = OsdPatchParamInit(fvarPatchParam.x,\n"
"                                            fvarPatchParam.y,\n"
"                                            fvarPatchParam.z);\n"
"\n"
"    int patchType = OsdPatchParamIsRegular(param) ? array.regDesc : array.desc;\n"
"\n"
"    float wP[20], wDu[20], wDv[20], wDuu[20], wDuv[20], wDvv[20];\n"
"    int numPoints = OsdEvaluatePatchBasisNormalized(patchType, param,\n"
"                uv.s, uv.t, wP, wDu, wDv, wDuu, wDuv, wDvv);\n"
"\n"
"    int patchArrayStride = numPoints;\n"
"\n"
"    int primOffset = patchIndex * patchArrayStride;\n"
"\n"
"    vec2 result = vec2(0);\n"
"    for (int i=0; i<numPoints; ++i) {\n"
"        int index = (primOffset+i)*OSD_FVAR_WIDTH + fvarOffset;\n"
"        vec2 cv = vec2(texelFetch(OsdFVarDataBuffer, index).s,\n"
"                       texelFetch(OsdFVarDataBuffer, index + 1).s);\n"
"        result += wP[i] * cv;\n"
"    }\n"
"\n"
"    return result;\n"
"}\n"
"\n"
"void emit(int index, vec3 normal)\n"
"{\n"
"    outpt.v.position = inpt[index].v.position;\n"
"    outpt.v.patchCoord = inpt[index].v.patchCoord;\n"
"#ifdef SMOOTH_NORMALS\n"
"    outpt.v.normal = inpt[index].v.normal;\n"
"#else\n"
"    outpt.v.normal = normal;\n"
"#endif\n"
"\n"
"#ifdef OSD_PATCH_ENABLE_SINGLE_CREASE\n"
"    outpt.vSegments = inpt[index].vSegments;\n"
"#endif\n"
"\n"
"#ifdef SHADING_VARYING_COLOR\n"
"    outpt.color = inpt[index].color;\n"
"#endif\n"
"\n"
"#ifdef SHADING_FACEVARYING_COLOR\n"
"#ifdef SHADING_FACEVARYING_UNIFORM_SUBDIVISION\n"
"    // interpolate fvar data at refined tri or quad vertex locations\n"
"#ifdef PRIM_TRI\n"
"    vec2 trist[3] = vec2[](vec2(0,0), vec2(1,0), vec2(0,1));\n"
"    vec2 st = trist[index];\n"
"#endif\n"
"#ifdef PRIM_QUAD\n"
"    vec2 quadst[4] = vec2[](vec2(0,0), vec2(1,0), vec2(1,1), vec2(0,1));\n"
"    vec2 st = quadst[index];\n"
"#endif\n"
"#else\n"
"    // interpolate fvar data at tessellated vertex locations\n"
"    vec2 st = inpt[index].v.tessCoord;\n"
"#endif\n"
"\n"
"    vec2 uv = interpolateFaceVarying(st, /*fvarOffset*/0);\n"
"    outpt.color = vec3(uv.s, uv.t, 0);\n"
"#endif\n"
"\n"
"    gl_Position = ProjectionMatrix * inpt[index].v.position;\n"
"    EmitVertex();\n"
"}\n"
"\n"
"#if defined(GEOMETRY_OUT_WIRE) || defined(GEOMETRY_OUT_LINE)\n"
"const float VIEWPORT_SCALE = 1024.0; // XXXdyu\n"
"\n"
"float edgeDistance(vec4 p, vec4 p0, vec4 p1)\n"
"{\n"
"    return VIEWPORT_SCALE *\n"
"        abs((p.x - p0.x) * (p1.y - p0.y) -\n"
"            (p.y - p0.y) * (p1.x - p0.x)) / length(p1.xy - p0.xy);\n"
"}\n"
"\n"
"void emit(int index, vec3 normal, vec4 edgeVerts[EDGE_VERTS])\n"
"{\n"
"    outpt.edgeDistance[0] =\n"
"        edgeDistance(edgeVerts[index], edgeVerts[0], edgeVerts[1]);\n"
"    outpt.edgeDistance[1] =\n"
"        edgeDistance(edgeVerts[index], edgeVerts[1], edgeVerts[2]);\n"
"#ifdef PRIM_TRI\n"
"    outpt.edgeDistance[2] =\n"
"        edgeDistance(edgeVerts[index], edgeVerts[2], edgeVerts[0]);\n"
"#endif\n"
"#ifdef PRIM_QUAD\n"
"    outpt.edgeDistance[2] =\n"
"        edgeDistance(edgeVerts[index], edgeVerts[2], edgeVerts[3]);\n"
"    outpt.edgeDistance[3] =\n"
"        edgeDistance(edgeVerts[index], edgeVerts[3], edgeVerts[0]);\n"
"#endif\n"
"\n"
"    emit(index, normal);\n"
"}\n"
"#endif\n"
"\n"
"void main()\n"
"{\n"
"    gl_PrimitiveID = gl_PrimitiveIDIn;\n"
"\n"
"#ifdef PRIM_QUAD\n"
"    vec3 A = (inpt[0].v.position - inpt[1].v.position).xyz;\n"
"    vec3 B = (inpt[3].v.position - inpt[1].v.position).xyz;\n"
"    vec3 C = (inpt[2].v.position - inpt[1].v.position).xyz;\n"
"    vec3 n0 = normalize(cross(B, A));\n"
"\n"
"#if defined(GEOMETRY_OUT_WIRE) || defined(GEOMETRY_OUT_LINE)\n"
"    vec4 edgeVerts[EDGE_VERTS];\n"
"    edgeVerts[0] = ProjectionMatrix * inpt[0].v.position;\n"
"    edgeVerts[1] = ProjectionMatrix * inpt[1].v.position;\n"
"    edgeVerts[2] = ProjectionMatrix * inpt[2].v.position;\n"
"    edgeVerts[3] = ProjectionMatrix * inpt[3].v.position;\n"
"\n"
"    edgeVerts[0].xy /= edgeVerts[0].w;\n"
"    edgeVerts[1].xy /= edgeVerts[1].w;\n"
"    edgeVerts[2].xy /= edgeVerts[2].w;\n"
"    edgeVerts[3].xy /= edgeVerts[3].w;\n"
"\n"
"    emit(0, n0, edgeVerts);\n"
"    emit(1, n0, edgeVerts);\n"
"    emit(3, n0, edgeVerts);\n"
"    emit(2, n0, edgeVerts);\n"
"#else\n"
"    emit(0, n0);\n"
"    emit(1, n0);\n"
"    emit(3, n0);\n"
"    emit(2, n0);\n"
"#endif\n"
"#endif // PRIM_QUAD\n"
"\n"
"#ifdef PRIM_TRI\n"
"    vec3 A = (inpt[0].v.position - inpt[1].v.position).xyz;\n"
"    vec3 B = (inpt[2].v.position - inpt[1].v.position).xyz;\n"
"    vec3 n0 = normalize(cross(B, A));\n"
"\n"
"#if defined(GEOMETRY_OUT_WIRE) || defined(GEOMETRY_OUT_LINE)\n"
"    vec4 edgeVerts[EDGE_VERTS];\n"
"    edgeVerts[0] = ProjectionMatrix * inpt[0].v.position;\n"
"    edgeVerts[1] = ProjectionMatrix * inpt[1].v.position;\n"
"    edgeVerts[2] = ProjectionMatrix * inpt[2].v.position;\n"
"\n"
"    edgeVerts[0].xy /= edgeVerts[0].w;\n"
"    edgeVerts[1].xy /= edgeVerts[1].w;\n"
"    edgeVerts[2].xy /= edgeVerts[2].w;\n"
"\n"
"    emit(0, n0, edgeVerts);\n"
"    emit(1, n0, edgeVerts);\n"
"    emit(2, n0, edgeVerts);\n"
"#else\n"
"    emit(0, n0);\n"
"    emit(1, n0);\n"
"    emit(2, n0);\n"
"#endif\n"
"#endif // PRIM_TRI\n"
"\n"
"    EndPrimitive();\n"
"}\n"
"\n"
"#endif\n"
"\n"
"//--------------------------------------------------------------\n"
"// Fragment Shader\n"
"//--------------------------------------------------------------\n"
"#ifdef FRAGMENT_SHADER\n"
"\n"
"in block {\n"
"    OutputVertex v;\n"
"    noperspective in vec4 edgeDistance;\n"
"#ifdef OSD_PATCH_ENABLE_SINGLE_CREASE\n"
"    vec2 vSegments;\n"
"#endif\n"
"    OSD_USER_VARYING_DECLARE\n"
"} inpt;\n"
"\n"
"out vec4 outColor;\n"
"\n"
"#define NUM_LIGHTS 2\n"
"\n"
"struct LightSource {\n"
"    vec4 position;\n"
"    vec4 direction;\n"
"    vec4 ambient;\n"
"    vec4 diffuse;\n"
"    vec4 specular;\n"
"    vec4 color;\n"
"    vec4 props;\n"
"};\n"
"\n"
"layout(std140) uniform Lighting {\n"
"    LightSource lightSource[NUM_LIGHTS];\n"
"};\n"
"\n"
"uniform vec4 diffuseColor = vec4(1);\n"
"uniform vec4 ambientColor = vec4(1);\n"
"uniform int NumLights;\n"
"uniform vec4 CamPos;\n"
"\n"
"vec4\n"
"elementWise(vec4 firstVec, vec4 secVec)\n"
"{\n"
"	vec4 result;\n"
"	for (int i = 0; i < 4; i++)\n"
"	{\n"
"		result[i] = firstVec[i] * secVec[i];\n"
"	}\n"
"\n"
"	return result;\n"
"}\n"
"\n"
"vec4\n"
"lighting(vec4 diffuse, vec3 Peye, vec3 Neye)\n"
"{\n"
"    vec4 color = vec4(0);\n"
"\n"
"    for (int i = 0; i < NumLights; ++i) {\n"
"        vec4 Plight = lightSource[i].position;\n"
"        vec4 Dlight = lightSource[i].direction;\n"
"        vec4 il;\n"
"        vec3 l, h, n, r;\n"
"        float d,s, temp;\n"
"\n"
"        switch(int(lightSource[i].props[0])){\n"
"           case(0):\n"
"               l = normalize( Dlight.xyz );\n"
"               il = lightSource[i].color;\n"
"               break;\n"
"           case(1):\n"
"               l = (Plight.w == 0.0)\n"
"                           ? normalize(Plight.xyz) : normalize(Plight.xyz - Peye);\n"
"               temp = distance(Plight.xyz, Peye);\n"
"               il = lightSource[i].color/(pow(temp, int(lightSource[i].props[1])));\n"
"               break;\n"
"           case(2):\n"
"               l = (Plight.w == 0.0)\n"
"                           ? normalize(Plight.xyz) : normalize(Plight.xyz - Peye);\n"
"               temp = distance(Plight.xyz, Peye);\n"
"               float angle = acos(dot(Dlight.xyz, l));\n"
"               il = (angle < radians(lightSource[i].props[3])) ? lightSource[i].color/(pow(temp, int(lightSource[i].props[1]))) * pow(cos(angle), int(lightSource[i].props[2])) : vec4(0);\n"
"               break;\n"
"        }\n"
"        n = normalize(Neye);\n"
"        r = normalize(reflect(l, n));\n"
"        h = normalize(l + vec3(0, 0, 1));    // directional viewer\n"
"\n"
"        d = max(0.0, dot(n, l));\n"
"        s = pow(max(0.0, dot(-r, h)), 500.0f);\n"
"\n"
"        color += lightSource[i].ambient * ambientColor\n"
"            + d * lightSource[i].diffuse * diffuse * il\n"
"            + s * lightSource[i].specular * il;\n"
"    }\n"
"\n"
"    color.a = 1;\n"
"    return color;\n"
"}\n"
"\n"
"vec4\n"
"edgeColor(vec4 Cfill, vec4 edgeDistance)\n"
"{\n"
"#if defined(GEOMETRY_OUT_WIRE) || defined(GEOMETRY_OUT_LINE)\n"
"#ifdef PRIM_TRI\n"
"    float d =\n"
"        min(inpt.edgeDistance[0], min(inpt.edgeDistance[1], inpt.edgeDistance[2]));\n"
"#endif\n"
"#ifdef PRIM_QUAD\n"
"    float d =\n"
"        min(min(inpt.edgeDistance[0], inpt.edgeDistance[1]),\n"
"            min(inpt.edgeDistance[2], inpt.edgeDistance[3]));\n"
"#endif\n"
"    float v = 0.8;\n"
"    vec4 Cedge = vec4(Cfill.r*v, Cfill.g*v, Cfill.b*v, 1);\n"
"    float p = exp2(-2 * d * d);\n"
"\n"
"#if defined(GEOMETRY_OUT_WIRE)\n"
"    if (p < 0.25) discard;\n"
"#endif\n"
"\n"
"    Cfill.rgb = mix(Cfill.rgb, Cedge.rgb, p);\n"
"#endif\n"
"    return Cfill;\n"
"}\n"
"\n"
"vec4\n"
"getAdaptivePatchColor(ivec3 patchParam)\n"
"{\n"
"    const vec4 patchColors[7*6] = vec4[7*6](\n"
"        vec4(1.0f,  1.0f,  1.0f,  1.0f),   // regular\n"
"        vec4(0.0f,  1.0f,  1.0f,  1.0f),   // regular pattern 0\n"
"        vec4(0.0f,  0.5f,  1.0f,  1.0f),   // regular pattern 1\n"
"        vec4(0.0f,  0.5f,  0.5f,  1.0f),   // regular pattern 2\n"
"        vec4(0.5f,  0.0f,  1.0f,  1.0f),   // regular pattern 3\n"
"        vec4(1.0f,  0.5f,  1.0f,  1.0f),   // regular pattern 4\n"
"\n"
"        vec4(1.0f,  0.5f,  0.5f,  1.0f),   // single crease\n"
"        vec4(1.0f,  0.70f,  0.6f,  1.0f),  // single crease pattern 0\n"
"        vec4(1.0f,  0.65f,  0.6f,  1.0f),  // single crease pattern 1\n"
"        vec4(1.0f,  0.60f,  0.6f,  1.0f),  // single crease pattern 2\n"
"        vec4(1.0f,  0.55f,  0.6f,  1.0f),  // single crease pattern 3\n"
"        vec4(1.0f,  0.50f,  0.6f,  1.0f),  // single crease pattern 4\n"
"\n"
"        vec4(0.8f,  0.0f,  0.0f,  1.0f),   // boundary\n"
"        vec4(0.0f,  0.0f,  0.75f, 1.0f),   // boundary pattern 0\n"
"        vec4(0.0f,  0.2f,  0.75f, 1.0f),   // boundary pattern 1\n"
"        vec4(0.0f,  0.4f,  0.75f, 1.0f),   // boundary pattern 2\n"
"        vec4(0.0f,  0.6f,  0.75f, 1.0f),   // boundary pattern 3\n"
"        vec4(0.0f,  0.8f,  0.75f, 1.0f),   // boundary pattern 4\n"
"\n"
"        vec4(0.0f,  1.0f,  0.0f,  1.0f),   // corner\n"
"        vec4(0.5f,  1.0f,  0.5f,  1.0f),   // corner pattern 0\n"
"        vec4(0.5f,  1.0f,  0.5f,  1.0f),   // corner pattern 1\n"
"        vec4(0.5f,  1.0f,  0.5f,  1.0f),   // corner pattern 2\n"
"        vec4(0.5f,  1.0f,  0.5f,  1.0f),   // corner pattern 3\n"
"        vec4(0.5f,  1.0f,  0.5f,  1.0f),   // corner pattern 4\n"
"\n"
"        vec4(1.0f,  1.0f,  0.0f,  1.0f),   // gregory\n"
"        vec4(1.0f,  1.0f,  0.0f,  1.0f),   // gregory\n"
"        vec4(1.0f,  1.0f,  0.0f,  1.0f),   // gregory\n"
"        vec4(1.0f,  1.0f,  0.0f,  1.0f),   // gregory\n"
"        vec4(1.0f,  1.0f,  0.0f,  1.0f),   // gregory\n"
"        vec4(1.0f,  1.0f,  0.0f,  1.0f),   // gregory\n"
"\n"
"        vec4(1.0f,  0.5f,  0.0f,  1.0f),   // gregory boundary\n"
"        vec4(1.0f,  0.5f,  0.0f,  1.0f),   // gregory boundary\n"
"        vec4(1.0f,  0.5f,  0.0f,  1.0f),   // gregory boundary\n"
"        vec4(1.0f,  0.5f,  0.0f,  1.0f),   // gregory boundary\n"
"        vec4(1.0f,  0.5f,  0.0f,  1.0f),   // gregory boundary\n"
"        vec4(1.0f,  0.5f,  0.0f,  1.0f),   // gregory boundary\n"
"\n"
"        vec4(1.0f,  0.7f,  0.3f,  1.0f),   // gregory basis\n"
"        vec4(1.0f,  0.7f,  0.3f,  1.0f),   // gregory basis\n"
"        vec4(1.0f,  0.7f,  0.3f,  1.0f),   // gregory basis\n"
"        vec4(1.0f,  0.7f,  0.3f,  1.0f),   // gregory basis\n"
"        vec4(1.0f,  0.7f,  0.3f,  1.0f),   // gregory basis\n"
"        vec4(1.0f,  0.7f,  0.3f,  1.0f)    // gregory basis\n"
"    );\n"
"\n"
"    int patchType = 0;\n"
"\n"
"    int edgeCount = bitCount(OsdGetPatchBoundaryMask(patchParam));\n"
"    if (edgeCount == 1) {\n"
"        patchType = 2; // BOUNDARY\n"
"    }\n"
"    if (edgeCount > 1) {\n"
"        patchType = 3; // CORNER (not correct for patches that are not isolated)\n"
"    }\n"
"\n"
"#if defined OSD_PATCH_ENABLE_SINGLE_CREASE\n"
"    // check this after boundary/corner since single crease patch also has edgeCount.\n"
"    if (inpt.vSegments.y > 0) {\n"
"        patchType = 1;\n"
"    }\n"
"#elif defined OSD_PATCH_GREGORY\n"
"    patchType = 4;\n"
"#elif defined OSD_PATCH_GREGORY_BOUNDARY\n"
"    patchType = 5;\n"
"#elif defined OSD_PATCH_GREGORY_BASIS\n"
"    patchType = 6;\n"
"#elif defined OSD_PATCH_GREGORY_TRIANGLE\n"
"    patchType = 6;\n"
"#endif\n"
"\n"
"    int pattern = bitCount(OsdGetPatchTransitionMask(patchParam));\n"
"\n"
"    return patchColors[6*patchType + pattern];\n"
"}\n"
"\n"
"vec4\n"
"getAdaptiveDepthColor(ivec3 patchParam)\n"
"{\n"
"    //  Represent depth with repeating cycle of four colors:\n"
"    const vec4 depthColors[4] = vec4[4](\n"
"        vec4(0.0f,  0.5f,  0.5f,  1.0f),\n"
"        vec4(1.0f,  1.0f,  1.0f,  1.0f),\n"
"        vec4(0.0f,  1.0f,  1.0f,  1.0f),\n"
"        vec4(0.5f,  1.0f,  0.5f,  1.0f)\n"
"    );\n"
"    return depthColors[OsdGetPatchRefinementLevel(patchParam) & 3];\n"
"}\n"
"\n"
"#if defined(PRIM_QUAD) || defined(PRIM_TRI)\n"
"void\n"
"main()\n"
"{\n"
"    vec3 N = (gl_FrontFacing ? inpt.v.normal : -inpt.v.normal);\n"
"\n"
"#if defined(SHADING_VARYING_COLOR)\n"
"    vec4 color = vec4(inpt.color, 1);\n"
"#elif defined(SHADING_FACEVARYING_COLOR)\n"
"    // generating a checkerboard pattern\n"
"    vec4 color = vec4(inpt.color.rg,\n"
"                      int(floor(20*inpt.color.r)+floor(20*inpt.color.g))&1, 1);\n"
"#elif defined(SHADING_PATCH_TYPE)\n"
"    vec4 color = getAdaptivePatchColor(OsdGetPatchParam(OsdGetPatchIndex(gl_PrimitiveID)));\n"
"#elif defined(SHADING_PATCH_DEPTH)\n"
"    vec4 color = getAdaptiveDepthColor(OsdGetPatchParam(OsdGetPatchIndex(gl_PrimitiveID)));\n"
"#elif defined(SHADING_PATCH_COORD)\n"
"    vec4 color = vec4(inpt.v.patchCoord.xy, 0, 1);\n"
"#elif defined(SHADING_MATERIAL)\n"
"    vec4 color = diffuseColor;\n"
"#else\n"
"    vec4 color = vec4(1, 1, 1, 1);\n"
"#endif\n"
"\n"
"    vec4 Cf = lighting(color, inpt.v.position.xyz, N);\n"
"\n"
"#if defined(SHADING_NORMAL)\n"
"    Cf.rgb = N;\n"
"#endif\n"
"\n"
"#if defined(GEOMETRY_OUT_WIRE) || defined(GEOMETRY_OUT_LINE)\n"
"    Cf = edgeColor(Cf, inpt.edgeDistance);\n"
"#endif\n"
"\n"
"    outColor = Cf;\n"
"}\n"
"#endif\n"
"\n"
"#endif\n"
"\n"
