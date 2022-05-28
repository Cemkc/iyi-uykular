using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VFXGrow : MonoBehaviour
{
    [SerializeField] private Material _dissolveMat;
    [SerializeField] private float _dissolveOuterSpeed;
    [SerializeField] private float _dissolveInnerSpeed;
    [SerializeField] private float _initDisOuter;
    [SerializeField] private float _initDisInner;
    [SerializeField] private float _duration;
    private float _disOuter = 0;
    private float _disInner = 0;
    private float _timer = 0;

    private void Start()
    {
        _disOuter = _initDisOuter;
        _disInner = _initDisInner;
        _dissolveMat.SetFloat("_Outer", _disOuter);
        _dissolveMat.SetFloat("_Inner", _disInner);
    }

    void Update()
    {
        Dissolve();
    }

    private void Dissolve()
    {
        _disOuter += _dissolveOuterSpeed * Time.deltaTime;
        _disInner += _dissolveInnerSpeed * Time.deltaTime;

        _dissolveMat.SetFloat("_Outer", _disOuter);
        _dissolveMat.SetFloat("_Inner", _disInner);

        if (_timer >= _duration)
        {
            foreach  (ParticleSystem particle in GetComponentsInChildren<ParticleSystem>())
            {
                particle.Stop();
            }
            Destroy(gameObject);
        }

        _timer += Time.deltaTime;
    }
}
