using System.Collections.Generic;
using UnityEngine;

public class GlobalAudioMaster : MonoBehaviour
{
    private AudioSource audioSource;
    [SerializeField] private List<AudioClip> audioClips;

    void Start()
    {
        audioSource = GetComponent<AudioSource>();
    }

    public void PlaySoundGlobal(int index)
    {
        audioSource.PlayOneShot(audioClips[index]);
    }
}
