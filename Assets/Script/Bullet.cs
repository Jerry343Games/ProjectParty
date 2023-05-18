using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    public float speed = 8f;  //子弹速度
    public GameObject player;
    [Tooltip("子弹存在时间")]
    public float bulletLifeTime;
    [Tooltip("启用伤害等待的时间，避免误伤")]
    public float unlockTime;
    public float dragForce;
    public bool isUnlocked;

    private Vector3 transA;
    private Vector3 transB;

    public bool isFireBullet;
    void Start()
    {
        isUnlocked = false;
        transA = transform.position;
        Destroy(gameObject,bulletLifeTime);  //1s后销毁自身
        StartCoroutine(UnlockDamage());
    }

    void Update()
    {
        transform.Translate(0, 0, Time.deltaTime * speed); //子弹位移     
    }

    private void OnTriggerEnter(Collider other)
    {
        var tagName = other.gameObject.tag;
        Debug.Log(tagName);
        if (tagName == "Player"&&isUnlocked)
        {
            
            //CreatRope(other.gameObject);
            Debug.Log("Hit!!!");
            AddDragForce(other.gameObject);
            Destroy(gameObject);
            if(other.GetComponent<GraspMilkBox>().isGrasping)
            {
                other.GetComponent<GraspMilkBox>().isHit = true;
            }
        }
        if (tagName == "MilkBox" || tagName == "Boom") 
        {
            AddDragForceToMilkBox(other.gameObject);
            Destroy(gameObject);
        }
        if (tagName == "GrassBall")
        {
            AddDragForceToGrassBall(other.gameObject);
            Destroy(gameObject);
        }
        if (tagName == "Obstacle")
        {
            
            Destroy(this);
        }
    }

    IEnumerator UnlockDamage()
    {
        yield return new WaitForSeconds(unlockTime);
        transB = transform.position;
        isUnlocked = true;
    }

    void AddDragForce(GameObject other)
    {
        Vector3 dragDir = transB - transA;
        if (isFireBullet)
        {
            dragDir = -dragDir;
            SoundsManager.PlayDamageAudio() ;
        }else
        {
            SoundsManager.PlayDragAudio();
        }
        other.GetComponent<Rigidbody>().AddForce(new Vector3(-dragDir.normalized.x, 1.5f, -dragDir.normalized.z) * dragForce);
    }

    void AddDragForceToMilkBox(GameObject other)
    {
        Vector3 dragDir = transB - transA;
        other.GetComponent<Rigidbody>().AddForce(new Vector3(-dragDir.normalized.x, 0.8f, -dragDir.normalized.z) * dragForce);
        SoundsManager.PlayDragAudio();
    }

    void AddDragForceToGrassBall(GameObject other)
    {
        Vector3 dragDir = transB - transA;
        if (isFireBullet)
        {
            dragDir = -dragDir;
        }
        SoundsManager.PlayDragAudio();
        other.GetComponent<Rigidbody>().AddForce(new Vector3(-dragDir.normalized.x, 0.8f, -dragDir.normalized.z) * dragForce*10);
    }
}