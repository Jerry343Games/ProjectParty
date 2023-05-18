using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundsManager : MonoBehaviour
{
    // Start is called before the first frame update

    public static AudioSource audioSource;
    public static AudioClip pickMilkBottom;
    public static AudioClip cannonFire;
    public static AudioClip boomExplosion;
    public static AudioClip throwRope;
    public static AudioClip playerFire;
    public static AudioClip deliverMilkBox;
    public static AudioClip drag;
    public static AudioClip playerDamage;
    void Start()
    {
        audioSource = GetComponent<AudioSource>();
        cannonFire = Resources.Load<AudioClip>("BoomExplosion");
        boomExplosion = Resources.Load<AudioClip>("BoomExplosion");
        playerFire = Resources.Load<AudioClip>("枪声");
        throwRope = Resources.Load<AudioClip>("投掷绳子");
        pickMilkBottom = Resources.Load<AudioClip>("拾取到物品");
        drag = Resources.Load<AudioClip>("物品被绳子牵动");
        playerDamage = Resources.Load<AudioClip>("被击中");
        deliverMilkBox = Resources.Load<AudioClip>("milkbox3");
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public static void PlayCannonFireAudio()
    {
        audioSource.PlayOneShot(cannonFire);
    }
    public static void PlayExplosionAudio()
    {
        audioSource.PlayOneShot(boomExplosion);
    }
    public static void PlayThrowAudio()
    {
        audioSource.PlayOneShot(throwRope);
    }
    public static void PlayFireAudio()
    {
        audioSource.PlayOneShot(playerFire);
    }
    public static void PlayCollectAudio()
    {
        audioSource.PlayOneShot(pickMilkBottom);
    }
    public static void PlayDragAudio()
    {
        audioSource.PlayOneShot(drag);
    }
    public static void PlayDamageAudio()
    {
        audioSource.PlayOneShot(playerDamage);
    }

    public static void PlayDeliverMilkBoxAudio()
    {
        audioSource.PlayOneShot(deliverMilkBox);
    }
}
