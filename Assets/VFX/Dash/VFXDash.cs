using UnityEngine;

public class VFXDash : MonoBehaviour
{
    private TrailRenderer _trailRenderer;

    void Start()
    {
        _trailRenderer = GetComponentInChildren<TrailRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        if (GameManager.instance.currentPlayerState == GameManager.PlayerStates.Dashing)
        {
            _trailRenderer.emitting = true;
        }
        else
        {
            _trailRenderer.emitting = false;
        }
    }
}
