using System;
using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

public class EasyToonEditor : ShaderGUI
{
    #region Utilities

    static GUIStyle boxScopeStyle;
    public static GUIStyle BoxScopeStyle
    {
        get
        {
            if (boxScopeStyle == null)
            {
                boxScopeStyle = new GUIStyle(EditorStyles.helpBox);
                var p = boxScopeStyle.padding;
                p.right += 6;
                p.top += 1;
                p.left += 3;
            }
            return boxScopeStyle;
        }
    }

    static GUIStyle toonLabelStyle;
    public static GUIStyle ToonLabelStyle
    {
        get
        {
            if (toonLabelStyle == null)
            {
                toonLabelStyle = new GUIStyle(EditorStyles.whiteLargeLabel);
                var p = toonLabelStyle.fontStyle = FontStyle.Bold;
            }
            return toonLabelStyle;
        }
    }
    #endregion

    #region RampVariables

    private static int s_previewWidth = 64;
    private static int s_width = 128;
    private static string s_texturePath;

    private Texture2D _cachedTexture;
    private Texture2D _cachedTexturePreview;

    private static Gradient s_gradient = new Gradient
    {
        mode = GradientMode.Fixed,
        colorKeys = new GradientColorKey[] { new GradientColorKey(Color.black, 0.5f), new GradientColorKey(Color.white, 1) },
        alphaKeys = new GradientAlphaKey[] { new GradientAlphaKey(1, 0), new GradientAlphaKey(1, 1) }
    };

    #endregion

    #region MaterialProperties

    MaterialProperty outlineUse = null;
    MaterialProperty outlineThicnkess = null;
    MaterialProperty outlineAdaptiveThicnkess = null;
    MaterialProperty outlineType = null;
    MaterialProperty outlineColor = null;
    MaterialProperty outlineTextureStrength = null;

    MaterialProperty albedoMap = null;
    MaterialProperty albedoColor = null;
    MaterialProperty occlusionMap = null;
    MaterialProperty occlusionStrength = null;
    MaterialProperty alphaClipThreshold = null;
    MaterialProperty normalMap = null;
    MaterialProperty normalMapStrength = null;
    MaterialProperty smoothness = null;
    MaterialProperty specularMap = null;
    MaterialProperty indirectLightStrength = null;

    MaterialProperty emissionUse = null;
    MaterialProperty emissionMap = null;
    MaterialProperty emissionColor = null;


    MaterialProperty rampMap = null;
    MaterialProperty lightRampUse = null;
    MaterialProperty stepOffset = null;
    MaterialProperty lightRampOffset = null;
    MaterialProperty rampDiffuseTextureLoaded = null;

    MaterialProperty diffusePosterizeOffset = null;
    MaterialProperty diffusePosterizePower = null;
    MaterialProperty diffusePosterizeSteps = null;
    MaterialProperty shadowColor = null;

    MaterialProperty useAdditionalLightsDiffuse = null;
    MaterialProperty additionalLightsDiffuseAmount = null;
    MaterialProperty additionalLightsFaloff = null;

    MaterialProperty specularUse = null;
    MaterialProperty additionalLightsSmoothnessMultiplier = null;
    MaterialProperty smoothnessMultiplier = null;
    MaterialProperty additionalLightsIntesity = null;
    MaterialProperty mainLightIntesity = null;
    MaterialProperty specularFaloff = null;
    MaterialProperty specularPosterizeSteps = null;
    MaterialProperty specularColor = null;
    MaterialProperty specularShadowMask = null;
    MaterialProperty environemntReflectionUse = null;
    MaterialProperty environemntStrength = null;

    MaterialProperty rimUse = null;
    MaterialProperty rimPower = null;
    MaterialProperty rimSmoothness = null;
    MaterialProperty rimColor = null;
    MaterialProperty rimThickness = null;
    MaterialProperty rimShadowColor = null;
    MaterialProperty rimSplitColor = null;

    #endregion

    #region EditorVariables
    
    MaterialEditor m_MaterialEditor;
    Material m_Material;

    #endregion

    public void FindProperties(MaterialProperty[] props)
    {
        outlineUse = FindProperty("_UseOutline", props);
        outlineThicnkess = FindProperty("_Thicnkess", props);
        outlineAdaptiveThicnkess = FindProperty("_AdaptiveThicnkess", props);
        outlineType = FindProperty("_OutlineType", props);
        outlineColor = FindProperty("_OutlineColor", props);
        outlineTextureStrength = FindProperty("_OutlineTextureStrength", props);

        albedoMap = FindProperty("_MainTex", props);
        albedoColor = FindProperty("_Color", props);
        occlusionMap = FindProperty("_OcclusionMap", props);
        occlusionStrength = FindProperty("_OcclusionStrength", props);
        alphaClipThreshold = FindProperty("_Cutoff", props);
        normalMap = FindProperty("_BumpMap", props);
        normalMapStrength = FindProperty("_NormalMapStrength", props);
        smoothness = FindProperty("_Glossiness", props);
        specularMap = FindProperty("_SpecGlossMap", props);
        specularColor = FindProperty("_SpecColor", props);
        specularShadowMask = FindProperty("_SpecularShadowMask", props);
        indirectLightStrength = FindProperty("_IndirectLightStrength", props);

        emissionUse = FindProperty("_UseEmission", props);
        emissionMap = FindProperty("_EmissionMap", props);
        emissionColor = FindProperty("_EmissionColor", props);


        rampMap = FindProperty("_LightRampTexture", props);
        lightRampUse = FindProperty("_UseLightRamp", props);
        stepOffset = FindProperty("_StepOffset", props);
        lightRampOffset = FindProperty("_LightRampOffset", props);
        rampDiffuseTextureLoaded = FindProperty("_RampDiffuseTextureLoaded", props);
        diffusePosterizeOffset = FindProperty("_DiffusePosterizeOffset", props);
        diffusePosterizePower = FindProperty("_DiffusePosterizePower", props);
        diffusePosterizeSteps = FindProperty("_DiffusePosterizeSteps", props);
        shadowColor = FindProperty("_ShadowColor", props);

        specularFaloff= FindProperty("_SpecularFaloff", props);
        smoothnessMultiplier = FindProperty("_SmoothnessMultiplier", props);
        additionalLightsSmoothnessMultiplier = FindProperty("_AdditionalLightsSmoothnessMultiplier", props);
        additionalLightsIntesity = FindProperty("_AdditionalLightsIntesity", props);
        mainLightIntesity = FindProperty("_MainLightIntesity", props);

        useAdditionalLightsDiffuse = FindProperty("_UseAdditionalLightsDiffuse", props);
        additionalLightsDiffuseAmount = FindProperty("_AdditionalLightsAmount", props);
        additionalLightsFaloff = FindProperty("_AdditionalLightsFaloff", props);

        specularPosterizeSteps = FindProperty("_SpecularPosterizeSteps", props);
        specularUse = FindProperty("_UseSpecular", props);
        environemntReflectionUse = FindProperty("_UseEnvironmentRefletion", props);
        environemntStrength = FindProperty("_Strength", props);

        rimUse = FindProperty("_UseRimLight", props);
        rimPower = FindProperty("_RimPower", props);
        rimSmoothness = FindProperty("_RimSmoothness", props);
        rimColor = FindProperty("_RimColor", props);
        rimThickness = FindProperty("_RimThickness", props);
        rimSplitColor = FindProperty("_RimSplitColor", props);
        rimShadowColor = FindProperty("_RimShadowColor", props);

    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {

        FindProperties(props);
        m_MaterialEditor = materialEditor;
        m_Material = materialEditor.target as Material;
        
        ShaderPropertiesGUI(m_Material, materialEditor);

        //materialEditor.PropertiesDefaultGUI(props);
    }

    public void ShaderPropertiesGUI(Material material, MaterialEditor materialEditor)
    {
        MainEditor();
        DiffuseLightEditor();
        SpecularLightEditor();
        OutlineEditor();
        RimEditor();

        EditorGUILayout.BeginVertical(BoxScopeStyle);
        EditorGUILayout.Space(2);
        
        GUILayout.Label("Advanced", ToonLabelStyle);
        
        EditorGUILayout.BeginVertical(BoxScopeStyle);
        EditorGUILayout.Space(2);
        
        m_MaterialEditor.RenderQueueField();
        m_MaterialEditor.EnableInstancingField();
        m_MaterialEditor.DoubleSidedGIField();
        
        EditorGUILayout.Space(2);
        EditorGUILayout.EndVertical();
        
        EditorGUILayout.Space(2);
        EditorGUILayout.EndVertical();

    }

    #region HelperFunctions

    private void DrawBoxSpace(string header, List<MaterialProperty> props)
    {
        EditorGUILayout.BeginVertical(BoxScopeStyle);
        EditorGUILayout.Space(2);

        GUILayout.Label(header, ToonLabelStyle);

        EditorGUILayout.BeginVertical(BoxScopeStyle);
        EditorGUILayout.Space(2);

        foreach (var prop in props)
        {
            DrawProperty(prop);
        }

        EditorGUILayout.Space(2);
        EditorGUILayout.EndVertical();

        EditorGUILayout.Space(2);
        EditorGUILayout.EndVertical();
    }

    private void DrawToggleBoxScope(MaterialProperty header,List<MaterialProperty> props)
    {
        EditorGUILayout.BeginVertical(BoxScopeStyle);
        EditorGUILayout.Space(2);

        DrawToggleHeader(header);


        bool isParamPropEnabled = !Mathf.Approximately(header.floatValue, 0f);
        if(isParamPropEnabled)
        {
            EditorGUILayout.BeginVertical(BoxScopeStyle);
            EditorGUILayout.Space(2);

            foreach (var prop in props)
            {
                DrawProperty(prop);
            }

            EditorGUILayout.Space(2);
            EditorGUILayout.EndVertical();
        }


        EditorGUILayout.Space(2);
        EditorGUILayout.EndVertical();
    }

    private void DrawProperty(MaterialProperty prop)
    {
        m_MaterialEditor.ShaderProperty(prop, prop.displayName);
        //var gc = new GUIContent();
        //m_MaterialEditor.ShaderProperty(prop, StylizedToonStyles.Find(prop.displayName));
    }

    private void DrawToggleHeader(MaterialProperty prop, string name = null)
    {
        if(string.IsNullOrEmpty(name))
        {
            name = prop.displayName.Replace("Use", "");
        }

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(name, ToonLabelStyle);
        m_MaterialEditor.ShaderProperty(prop, string.Empty);

        EditorGUILayout.EndHorizontal();
        EditorGUILayout.Space();

    }

    #endregion

    #region EditorFunctions

    private void MainEditor()
    {
        EditorGUILayout.BeginVertical(BoxScopeStyle);
        EditorGUILayout.Space(2);

        GUILayout.Label("Main", ToonLabelStyle);

        EditorGUILayout.BeginVertical(BoxScopeStyle);
        EditorGUILayout.Space(2);

        m_MaterialEditor.TexturePropertySingleLine(new GUIContent("Albedo"), albedoMap, albedoColor);
        DrawProperty(alphaClipThreshold);

        DrawProperty(indirectLightStrength);

        m_MaterialEditor.TexturePropertySingleLine(new GUIContent("Normal Map"), normalMap, normalMapStrength);
        m_MaterialEditor.TexturePropertySingleLine(new GUIContent("Occlusion Map"), occlusionMap, occlusionStrength);

        bool emission = m_MaterialEditor.EmissionEnabledProperty();
        if (emission) emissionUse.floatValue = 1;
        else emissionUse.floatValue = 0;

        using (var disableScope = new EditorGUI.DisabledScope(!emission))
        {
            EditorGUILayout.BeginHorizontal();
            m_MaterialEditor.TexturePropertyWithHDRColor(new GUIContent("Emission Map"), emissionMap, emissionColor, false);
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.Space();

        m_MaterialEditor.TextureScaleOffsetProperty(occlusionMap);


        EditorGUILayout.Space(2);
        EditorGUILayout.EndVertical();

        EditorGUILayout.Space(2);
        EditorGUILayout.EndVertical();
    }

    private void RimEditor()
    {

        EditorGUILayout.BeginVertical(BoxScopeStyle);
        EditorGUILayout.Space(2);

        DrawToggleHeader(rimUse);

        bool isParamPropEnabled = !Mathf.Approximately(rimUse.floatValue, 0f);
        if (isParamPropEnabled)
        {
            EditorGUILayout.BeginVertical(BoxScopeStyle);
            EditorGUILayout.Space(2);

            
            DrawProperty(rimColor);
            DrawProperty(rimPower);
            DrawProperty(rimSmoothness);
            DrawProperty(rimThickness);

            DrawProperty(rimSplitColor);
            if(rimSplitColor.floatValue == 2)
            {
                DrawProperty(rimShadowColor);
            }


            EditorGUILayout.Space(2);
            EditorGUILayout.EndVertical();

        }

        EditorGUILayout.Space(2);
        EditorGUILayout.EndVertical();
    }

    private void DiffuseLightEditor()
    {
        EditorGUILayout.BeginVertical(BoxScopeStyle);
        EditorGUILayout.Space(2);

        GUILayout.Label("Toon Shading", ToonLabelStyle);

        EditorGUILayout.BeginVertical(BoxScopeStyle);
        EditorGUILayout.Space(2);

        DrawProperty(lightRampUse);

        //bool isParamPropEnabled = !Mathf.Approximately(lightRampUse.floatValue, 0f);

        if(lightRampUse.floatValue == 0)
        {
            //m_Material.DisableKeyword("_USELIGHTRAMPON");
            DrawProperty(stepOffset);
            DrawProperty(shadowColor);

        }
        else if(lightRampUse.floatValue == 1)
        {
            //m_Material.EnableKeyword("_USELIGHTRAMPON");
            DrawProperty(lightRampOffset);

            EditorGUILayout.BeginHorizontal();

            EditorGUI.BeginChangeCheck();
            DrawProperty(rampMap);
            if (EditorGUI.EndChangeCheck())
            {
                rampDiffuseTextureLoaded.floatValue = 1;
            }

            EditorGUI.BeginChangeCheck();
            EditorGUILayout.GradientField(s_gradient);
            if (EditorGUI.EndChangeCheck())
            {
                _cachedTexturePreview = UpdateTex(s_previewWidth);
                rampMap.textureValue = _cachedTexturePreview;
                rampDiffuseTextureLoaded.floatValue = 0;
            }

            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Space();

            using (var disableScope = new EditorGUI.DisabledScope(rampDiffuseTextureLoaded.floatValue == 1))
            {
                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("Set path for texture PNG"))
                {
                    SetTexturePath();
                }


                if (GUILayout.Button("Export as PNG"))
                {
                    _cachedTexture = UpdateTex(s_width);

                    ExportToPNG(_cachedTexture);

                    rampDiffuseTextureLoaded.floatValue = 0;
                    rampMap.textureValue = null;
                }

                EditorGUILayout.EndHorizontal();

                s_texturePath = GUILayout.TextField(s_texturePath);
            }


        }
        else if(lightRampUse.floatValue == 2)
        {
            DrawProperty(shadowColor);
            DrawProperty(diffusePosterizeOffset);
            DrawProperty(diffusePosterizeSteps);
            DrawProperty(diffusePosterizePower);

        }

        EditorGUILayout.Space(2);
        EditorGUILayout.EndVertical();

        EditorGUILayout.Space();

        DrawToggleBoxScope(useAdditionalLightsDiffuse,
           new List<MaterialProperty>
           {
                additionalLightsDiffuseAmount,additionalLightsFaloff
           }
           );

        EditorGUILayout.Space(2);
        EditorGUILayout.EndVertical();
    }

    private void SpecularLightEditor()
    {
        EditorGUILayout.BeginVertical(BoxScopeStyle);
        EditorGUILayout.Space(2);

        GUILayout.Label("Specular Shading", ToonLabelStyle);

        EditorGUILayout.BeginVertical(BoxScopeStyle);
        EditorGUILayout.Space(2);

        m_MaterialEditor.TexturePropertySingleLine(new GUIContent("Specular Map"), specularMap, specularColor);
        DrawProperty(smoothness);


        EditorGUILayout.Space(2);
        EditorGUILayout.EndVertical();

        List<MaterialProperty> list = new List<MaterialProperty>
            {
                smoothnessMultiplier,mainLightIntesity,additionalLightsSmoothnessMultiplier,additionalLightsIntesity,specularFaloff,specularPosterizeSteps,specularShadowMask
            };

        EditorGUILayout.BeginVertical(BoxScopeStyle);
        EditorGUILayout.Space(2);


        DrawToggleHeader(specularUse);

        bool isParamPropEnabled = !Mathf.Approximately(specularUse.floatValue, 0f);
        if (isParamPropEnabled)
        {
            EditorGUILayout.BeginVertical(BoxScopeStyle);
            EditorGUILayout.Space(2);

            foreach (var prop in list)
            {
                DrawProperty(prop);
            }

            EditorGUILayout.Space(2);
            EditorGUILayout.EndVertical();
        }

        EditorGUILayout.Space(2);
        EditorGUILayout.EndVertical();


        DrawToggleBoxScope(environemntReflectionUse,
           new List<MaterialProperty>
           {
               environemntStrength
           }
           );


        EditorGUILayout.Space(2);
        EditorGUILayout.EndVertical();
    }

    private void OutlineEditor()
    {
        List<MaterialProperty> list = new List<MaterialProperty>
            {
                outlineThicnkess,outlineAdaptiveThicnkess,outlineType,outlineColor,outlineTextureStrength
            };

        EditorGUILayout.BeginVertical(BoxScopeStyle);
        EditorGUILayout.Space(2);


        DrawToggleHeader(outlineUse);

        bool isParamPropEnabled = !Mathf.Approximately(outlineUse.floatValue, 0f);
        if (isParamPropEnabled)
        {
            EditorGUILayout.BeginVertical(BoxScopeStyle);
            EditorGUILayout.Space(2);

            foreach (var prop in list)
            {
                DrawProperty(prop);
            }

            EditorGUILayout.Space(2);
            EditorGUILayout.EndVertical();
        }

        EditorGUILayout.Space(2);
        EditorGUILayout.EndVertical();
    }

    #endregion

    #region RampFunctions

    private Texture2D UpdateTex(int width)
    {
        Texture2D tex = new Texture2D(width, 1, TextureFormat.RGBA32, false,false);
        tex.wrapMode = TextureWrapMode.Clamp;
        tex.filterMode = FilterMode.Bilinear;
        tex.name = "RampTexture";

        var colors = new Color[tex.width * tex.height];
        for (int x = 0; x < width; ++x)
        {
            colors[x] = s_gradient.Evaluate(1.0f * x / (width - 1));
        }
        tex.SetPixels(colors);
        tex.Apply();


        return tex;
    }

    private void ExportToPNG(Texture2D rampTex)
    {
        var savePath = s_texturePath;

        if (string.IsNullOrEmpty(savePath))
        {
            SetTexturePath();

            savePath = s_texturePath;

            var bytes = rampTex.EncodeToPNG();
            System.IO.File.WriteAllBytes(savePath, bytes);
            AssetDatabase.Refresh();
        }

        if (!string.IsNullOrEmpty(savePath))
        {
            var bytes = rampTex.EncodeToPNG();
            System.IO.File.WriteAllBytes(savePath, bytes);
            AssetDatabase.Refresh();
        }

        //rampMap.textureValue = (Texture)AssetDatabase.LoadMainAssetAtPath(savePath);

    }

    private void SetTexturePath()
    {
        var currentRampObjPath = AssetDatabase.GetAssetPath(m_MaterialEditor.serializedObject.targetObject);
        var defaultDirectory = System.IO.Path.GetDirectoryName(currentRampObjPath);
        s_texturePath = EditorUtility.SaveFilePanelInProject("Export as PNG file", "LightRamp", "png", "Set file path for the PNG file", defaultDirectory);
    }
    #endregion

}
