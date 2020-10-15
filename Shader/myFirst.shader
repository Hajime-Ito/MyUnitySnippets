Shader "Custom/sample"
{
    Properties
    {
        /*
        Parameters部分
        インスペクタに公開する変数を書く．
        C#でいうpublic変数のようなもの．
        */
        _Color ("Color", Color) = (1,1,1,1) // Colorでカラーピッカーを使用できる
        _MainTex ("Albedo (RGB)", 2D) = "white" {} // 2Dでテクスチャを設定できる
        _Glossiness ("Smoothness", Range(0,1)) = 0.5 // 範囲制限付きの数値をスライダーで設定できる
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }

    SubShader
    // Unityがメッシュを描画するとき、使用するシェーダーを見つけ、グラフィックスカードで実行する最初のサブシェーダー
  
    {
        /*  
        Shader Setting部分
        ライティングや透明度などのシェーダの設定項目を記述する．
        */

        Tags { "RenderType"="Opaque" }
        LOD 200 /* Level of Detail　描画クオリティの設定 */

        CGPROGRAM // プログラムの開始位置(以下にプログラムを書いていく) 
        /* 
        構文：#pragma surface 関数名 ライティングモデルオプション 
        #pragmaは「pragmaディレクティブ」と呼ぶ。これは、「サーフェースシェーダーを使用する」という意味
        関数名は各自が自由に設定できるが、Unityではデフォルトで「surf」が使われている
        ライティングモデルオプションが「fullforwardshadows」
        fullforwardshadowsは、フォワードレンダリングで、ポイントライトやスポットライトを使いたい場合に必要
        ライティングモデルオプションには「Standard」「Lambert」（拡散反射光）、「BlinnPhong」（鏡面反射光のモデルであるSpecular）
        の指定ができる
        今回のライティングモデルはSurfaceOutputStandard(実際にsurf関数内のinoutにSurfaceOutputStandartが指定されている)
        */
        #pragma surface surf Standard fullforwardshadows

        /*
        Surface Shader部分
        シェーダ本体のプログラムを書く．
        */

        #pragma target 3.0 //構文：#pragma target シェーダーモデル

        sampler2D _MainTex; // _MainTexプロパティはAlbedo（RGB）を呼び出す場合に使われる

        struct Input // 入力構造体部分
        {
            /*
            uとvの2次元座標なので、float2を利用
            uv座標を宣言している
            */
            float2 uv_MainTex;
        };

        half _Glossiness; // 滑らかさを表す
        half _Metallic; // 表面の反射性を表す
        fixed4 _Color; // 色を表す(R, G, B, A)なのでfloat4を選んでいる

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

       /*
       inは入力用の指定、outは出力用、inoutは入出力, outとinoutは参照渡しになる.
       inで入力された値は関数内で変更できず、out指定の引数は数値を参照渡しできても読み取りが出来ない
       inoutは参照渡しで、数値を参照渡しできるけど呼び出しもとで設定しておいた数値を読み取ることも出来る
       */
       /*
           struct SurfaceOutputStandard
           {
            fixed3 Albedo;        ベース（ディフューズまたはスペキュラ）カラー、デフォルトは黒
            fixed3 Normal;        法線（X,Y,Z）、デフォルトは設定なし
            half3 Emission;       表面から放出される光の色と強度を制御する
            half Metallic;          金属か否か（0=金属ではない, 1=金属）
            half Smoothness;   滑らかさの度合い（0=粗い, 1=滑らか）
            half Occlusion;       オクルージョン（遮蔽（しゃへい））、デフォルトは1で0の場合は完全遮蔽
            fixed Alpha;           不透明度（0～1）、デフォルトは0
            };
       */
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            /*
            tex2D関数は、UV座標（uv_MainTex）からテクスチャ（_MainTex）上のピクセルの色を計算して返す関数
            */
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            /*
            Properties内で_Gossinessを定義しないで、_Metallicだけを定義しただけでは、オブジェクトに光沢が表示されない
            */
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG /* プログラムの終了位置(ここでプログラムを閉じる) */
    }
   
    /*
    構文：FallBack "すべり止めシェーダー名"
    「すべり止め」とは、「もし、SubShaderの中に記述したシェーダープログラムが、
    ビデオカードでサポートされていない場合は、Unityのビルドインシェーダー「Diffuse」を使用する」という意味
    */
    FallBack "Diffuse"
}
