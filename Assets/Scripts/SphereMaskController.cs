using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class SphereMaskController : MonoBehaviour
{
    public float radius = 0.5f;
    [Range(0, 1)] public float softness = 0.5f;

    void Update()
    {
        Shader.SetGlobalVector("_GLOBALMaskPosition", transform.position);
        Shader.SetGlobalFloat("_GLOBALMaskRadius", radius);
        Shader.SetGlobalFloat("_GLOBALMaskSoftness", softness);
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, radius);
    }
}
