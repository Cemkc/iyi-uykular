using System.Collections;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class StageMaster : MonoBehaviour
{
    [SerializeField] private Orbit _orbit;

    [SerializeField] [Range(0, 1)] private float speed = 0.06f;

    [SerializeField] private GameObject _masks;

    [SerializeField] private GameObject _bookOpen;
    [SerializeField] private GameObject _bookClose;
    [SerializeField] private GameObject _bookFinal;

    [SerializeField] private DialogueMaster _dialogueMaster;

    [SerializeField] private ForwardRendererData _renderer;

    private bool _isCorutineRunning = false;

    public bool _test = false;

    private bool _isCamera1Done = false;
    private bool _isCamera2Done = false;

    void Start()
    {
        _orbit._angle = 0;
        _orbit._cameraPitch = 40f;
        _orbit._cameraRadius = -50f;

        MaskState(false);
    }

    void Update()
    {
        if (_test)
        {          
            _dialogueMaster.PlaySegment(0);
            _test = false;
        }
    }

    public void MoveCamera1()
    {
        if (!_isCorutineRunning)
        {
            _bookOpen.GetComponent<Animator>().SetBool("Open", true);
            StartCoroutine(MoveToGameSetting(0f, 20f, -5f, 0));
        }
    }

    public void MoveCamera2()
    {
        if (!_isCorutineRunning)
        {
            StartCoroutine(MoveToGameSetting(-45f, 7.5f, -10f, 1));
        }
    }

    public void MoveCamera3()
    {

        if (!_isCorutineRunning)
        {
            _bookClose.GetComponent<Animator>().SetBool("Close", true);
            StartCoroutine(MoveToGameSetting(0, 40, -50, 2));
        }
    }

    IEnumerator MoveToGameSetting(float angle, float pitch, float radius, int index)
    {
        _isCorutineRunning = true;

        Vector3 values;

        while (true)
        {         
            yield return new WaitForSecondsRealtime(0.01f);

            Vector3 firstpos = new Vector3(_orbit._angle, _orbit._cameraPitch, _orbit._cameraRadius);
            Vector3 lastpos = new Vector3(angle, pitch, radius);

            values = Vector3.Lerp(firstpos, lastpos, speed);

            _orbit._angle = values.x;
            _orbit._cameraPitch = values.y;
            _orbit._cameraRadius = values.z;

            if (Vector3.Distance(new Vector3(_orbit._angle, _orbit._cameraPitch, _orbit._cameraRadius), lastpos) <= 1f)
            {
                Debug.Log("sdfs");
                break;
            }
        }
        _isCorutineRunning = false;
        if (index == 1) { MaskState(true); }
        if (index == 2) { MaskState(false); }
        yield break;
    }

    public void MaskState(bool state)
    {
        if (state)
        {
            _masks.SetActive(true);
            foreach (var feature in _renderer.rendererFeatures)
            {
                feature.SetActive(true);
            }
        }
        else
        {
            _masks.SetActive(false);
            foreach (var feature in _renderer.rendererFeatures)
            {
                feature.SetActive(false);
            }
        }
    }

    public void SpawnFinalBookModel()
    {
        _bookFinal.SetActive(true);
    }

    public void RemoveFinalBookModel()
    {
        _bookFinal.SetActive(false);
    }

    public void RemoveOpenBookModel()
    {
        _bookOpen.SetActive(false);
    }

    public void SpawnCloseBookModel()
    {
        _bookClose.SetActive(true);
    }

}
