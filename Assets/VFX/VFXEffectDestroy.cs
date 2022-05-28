using UnityEngine;
using UnityEngine.VFX;

public class VFXEffectDestroy : MonoBehaviour
{
    [SerializeField] private float _lifeTime;
    private VisualEffect _particleSystem;
    private float _timer;

    private void Start()
    {
        _timer = 0;
        _particleSystem = GetComponentInChildren<VisualEffect>();
    }

    void Update()
    {
        _timer += Time.deltaTime;

        if (_timer >= _lifeTime)
        {
            _particleSystem.Stop();
            Destroy(gameObject);
        }
    }
}
