using UnityEngine;

public class VFXDissolve : MonoBehaviour
{
    [SerializeField] private Material _dissolveMat;
    [SerializeField] private float _dissolveOuterSpeed;
    [SerializeField] private float _dissolveInnerSpeed;
    private float _disOuter = 0;
    private float _disInner = 0;
    private ParticleSystem _particleSystem;

    private void Start()
    {
        _particleSystem = GetComponent<ParticleSystem>();
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

        if (_disOuter >= 50 && _disInner >= 70)
        {
            _particleSystem.Stop();
            Destroy(gameObject);
        }
    }
}
